{...}: {
  flake.nixosModules.prosody = {
    config,
    lib,
    pkgs,
    ...
  }: {
    sops.secrets."coturn/static-auth-secret" = {};

    networking.firewall = {
      allowedTCPPorts = [5222 5269 5000 3478 5349];
      allowedUDPPorts = [3478 5349];
      allowedUDPPortRanges = [
        {
          from = 49152;
          to = 49200;
        }
      ];
    };

    services = {
      postgresql = {
        enable = true;
        ensureDatabases = ["prosody"];
        ensureUsers = [
          {
            name = "prosody";
            ensureDBOwnership = true;
          }
        ];
      };

      coturn = {
        enable = true;
        realm = "myles.onl";
        use-auth-secret = true;
        static-auth-secret-file = config.sops.secrets."coturn/static-auth-secret".path;
        listening-port = 3478;
        tls-listening-port = 5349;
        min-port = 49152;
        max-port = 49200;
        cert = "/var/lib/acme/myles.onl/fullchain.pem";
        pkey = "/var/lib/acme/myles.onl/key.pem";
        no-cli = true;
        extraConfig = ''
          fingerprint
          no-multicast-peers
          no-loopback-peers
          denied-peer-ip=0.0.0.0-0.255.255.255
          denied-peer-ip=10.0.0.0-10.255.255.255
          denied-peer-ip=100.64.0.0-100.127.255.255
          denied-peer-ip=127.0.0.0-127.255.255.255
          denied-peer-ip=169.254.0.0-169.254.255.255
          denied-peer-ip=172.16.0.0-172.31.255.255
          denied-peer-ip=192.0.0.0-192.0.0.255
          denied-peer-ip=192.168.0.0-192.168.255.255
          denied-peer-ip=224.0.0.0-239.255.255.255
        '';
      };

      prosody = {
        enable = true;
        allowRegistration = false;
        authentication = "internal_hashed";
        admins = ["myles@myles.onl"];

        package = pkgs.prosody.override {
          withExtraLuaPackages = luaPackages: [luaPackages.luadbi-postgresql];
        };

        ssl = {
          cert = "/var/lib/acme/myles.onl/fullchain.pem";
          key = "/var/lib/acme/myles.onl/key.pem";
        };

        httpInterfaces = ["127.0.0.1"];
        httpsPorts = [];

        modules = {
          bosh = true;
          http_files = true;
          proxy65 = true;
          server_contact_info = true;
          websocket = true;
        };

        extraModules = ["external_services"];

        virtualHosts."myles.onl" = {
          domain = "myles.onl";
          enabled = true;
        };

        muc = [
          {
            domain = "conference.myles.onl";
            name = "Myles Chatrooms";
            restrictRoomCreation = "local";
            maxHistoryMessages = 100;
          }
        ];

        httpFileShare = {
          domain = "upload.myles.onl";
          http_host = "upload.myles.onl";
          http_external_url = "https://upload.myles.onl/";
          size_limit = 100 * 1024 * 1024;
          daily_quota = 1024 * 1024 * 1024;
          expires_after = "4 weeks";
        };

        disco_items = [
          {
            url = "https://chat.myles.onl";
            description = "Movim web chat";
          }
        ];

        extraConfig = ''
          storage = "sql"
          sql = {
            driver = "PostgreSQL";
            database = "prosody";
            username = "prosody";
          }

          archive_expires_after = "6 months"
          default_archive_policy = true
          contact_info = {
            abuse = { "xmpp:myles@myles.onl" };
            admin = { "xmpp:myles@myles.onl" };
          }

          external_service_host = "turn.myles.onl"
          external_service_port = 3478
          external_service_ttl = 86400
          external_service_secret = "@turn-secret@"
          external_services = {
            { type = "stun", transport = "udp" };
            { type = "turn", transport = "udp", secret = true };
            { type = "turn", transport = "tcp", secret = true };
          }
        '';
      };

      nginx.virtualHosts = {
        "xmpp.myles.onl" = {
          useACMEHost = "myles.onl";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:5280";
            proxyWebsockets = true;
          };
        };

        "upload.myles.onl" = {
          useACMEHost = "myles.onl";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:5280";
            proxyWebsockets = true;
            extraConfig = ''
              client_max_body_size 100M;
              proxy_request_buffering off;
            '';
          };
        };
      };
    };

    users.users = {
      prosody.extraGroups = ["nginx"];
      turnserver.extraGroups = ["nginx"];
    };

    systemd.services.prosody = {
      after = ["postgresql.service"];
      requires = ["postgresql.service"];
      preStart = lib.mkAfter ''
        ${pkgs.replace-secret}/bin/replace-secret \
          "@turn-secret@" \
          ${config.sops.secrets."coturn/static-auth-secret".path} \
          /run/prosody/prosody.cfg.lua
        chown prosody:prosody /run/prosody/prosody.cfg.lua
        chmod 0600 /run/prosody/prosody.cfg.lua
      '';
    };
  };
}
