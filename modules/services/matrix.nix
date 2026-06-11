{...}: {
  flake.nixosModules.matrix = {
    config,
    lib,
    pkgs,
    ...
  }: let
    synapseSecrets = "/run/matrix-synapse/secrets.yaml";
    elementConfig = builtins.toJSON {
      default_server_config = {
        "m.homeserver" = {
          base_url = "https://matrix.myles.onl";
          server_name = "myles.onl";
        };
      };
      disable_custom_urls = false;
      disable_guests = true;
      brand = "Element";
    };
  in {
    services = {
      postgresql = {
        enable = true;
      };

      matrix-synapse = {
        enable = true;
        enableRegistrationScript = true;
        extraConfigFiles = [synapseSecrets];
        settings = {
          server_name = "myles.onl";
          public_baseurl = "https://matrix.myles.onl/";
          enable_registration = false;
          report_stats = false;
          suppress_key_server_warning = true;
          max_upload_size = "100M";
          dynamic_thumbnails = true;

          database = {
            name = "psycopg2";
            args = {
              database = "matrix-synapse";
              user = "matrix-synapse";
            };
          };

          listeners = [
            {
              port = 8008;
              bind_addresses = ["127.0.0.1"];
              type = "http";
              tls = false;
              x_forwarded = true;
              resources = [
                {
                  names = ["client"];
                  compress = true;
                }
                {
                  names = ["federation"];
                  compress = false;
                }
              ];
            }
          ];

          turn_uris = [
            "turn:turn.myles.onl:3478?transport=udp"
            "turn:turn.myles.onl:3478?transport=tcp"
            "turns:turn.myles.onl:5349?transport=tcp"
          ];
          turn_user_lifetime = "86400000";
        };
      };

      nginx.virtualHosts = {
        "myles.onl" = {
          locations = {
            "= /.well-known/matrix/client".extraConfig = ''
              default_type application/json;
              more_set_headers "Access-Control-Allow-Origin: *";
              return 200 '{"m.homeserver":{"base_url":"https://matrix.myles.onl"}}';
            '';
            "= /.well-known/matrix/server".extraConfig = ''
              default_type application/json;
              return 200 '{"m.server":"matrix.myles.onl:443"}';
            '';
          };
        };

        "matrix.myles.onl" = {
          useACMEHost = "myles.onl";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8008";
            extraConfig = ''
              client_max_body_size 100M;
            '';
          };
        };

        "element.myles.onl" = {
          useACMEHost = "myles.onl";
          forceSSL = true;
          root = pkgs.element-web;
          locations."= /config.json".extraConfig = ''
            default_type application/json;
            return 200 '${elementConfig}';
          '';
        };
      };
    };

    users.users.matrix-synapse.extraGroups = ["turn-secret"];

    systemd.services.matrix-synapse-db-init = {
      description = "Create Matrix Synapse PostgreSQL database";
      after = ["postgresql.service"];
      requires = ["postgresql.service"];
      before = ["matrix-synapse.service"];

      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Group = "postgres";
      };

      script = ''
        set -euo pipefail

        psql=${config.services.postgresql.package}/bin/psql
        createuser=${config.services.postgresql.package}/bin/createuser
        createdb=${config.services.postgresql.package}/bin/createdb
        dropdb=${config.services.postgresql.package}/bin/dropdb
        tr=${pkgs.coreutils}/bin/tr

        role_exists=$($psql -tAc "SELECT 1 FROM pg_roles WHERE rolname = 'matrix-synapse'" | $tr -d '[:space:]')
        if [ "$role_exists" != "1" ]; then
          $createuser --no-createdb --no-createrole --no-superuser matrix-synapse
        fi

        db_exists=$($psql -tAc "SELECT 1 FROM pg_database WHERE datname = 'matrix-synapse'" | $tr -d '[:space:]')
        if [ "$db_exists" != "1" ]; then
          $createdb --encoding=UTF8 --locale=C --template=template0 --owner=matrix-synapse matrix-synapse
          exit 0
        fi

        collation=$($psql -tAc "SELECT datcollate FROM pg_database WHERE datname = 'matrix-synapse'" | $tr -d '[:space:]')
        ctype=$($psql -tAc "SELECT datctype FROM pg_database WHERE datname = 'matrix-synapse'" | $tr -d '[:space:]')
        if [ "$collation" = "C" ] && [ "$ctype" = "C" ]; then
          exit 0
        fi

        table_count=$($psql -d matrix-synapse -tAc "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public'" | $tr -d '[:space:]')
        if [ "$table_count" != "0" ]; then
          echo "matrix-synapse database exists with locale $collation/$ctype and is not empty; refusing to recreate" >&2
          exit 1
        fi

        $dropdb matrix-synapse
        $createdb --encoding=UTF8 --locale=C --template=template0 --owner=matrix-synapse matrix-synapse
      '';
    };

    systemd.services.matrix-synapse = {
      after = ["matrix-synapse-db-init.service"];
      requires = ["matrix-synapse-db-init.service"];
    };

    systemd.services.matrix-synapse.preStart = lib.mkBefore ''
      set -euo pipefail

      if [ ! -s /var/lib/matrix-synapse/registration_shared_secret ]; then
        umask 0077
        ${pkgs.coreutils}/bin/head -c 48 /dev/urandom \
          | ${pkgs.coreutils}/bin/base64 --wrap=0 \
          > /var/lib/matrix-synapse/registration_shared_secret
      fi

      {
        printf 'registration_shared_secret: |-\n  '
        ${pkgs.coreutils}/bin/tr -d '\n' < /var/lib/matrix-synapse/registration_shared_secret
        printf '\nturn_shared_secret: |-\n  '
        ${pkgs.coreutils}/bin/tr -d '\n' < ${config.sops.secrets."coturn/static-auth-secret".path}
        printf '\n'
      } > ${synapseSecrets}

      chmod 0600 ${synapseSecrets}
    '';
  };
}
