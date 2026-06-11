{...}: {
  flake.nixosModules.searx = {pkgs, ...}: {
    services = {
      searx = {
        enable = true;
        domain = "search.myles.onl";
        configureNginx = true;
        redisCreateLocally = true;
        environmentFile = "/var/lib/searx/searx.env";

        settings = {
          use_default_settings = true;

          general = {
            debug = false;
            instance_name = "Myles Search";
            enable_metrics = false;
          };

          search = {
            safe_search = 1;
            autocomplete = "duckduckgo";
            default_lang = "auto";
            formats = [
              "html"
              "json"
              "rss"
              "csv"
            ];
          };

          server = {
            base_url = "https://search.myles.onl/";
            image_proxy = true;
            limiter = true;
            method = "POST";
            public_instance = false;
            secret_key = "$SEARX_SECRET_KEY";
          };

          ui = {
            static_use_hash = true;
            default_theme = "simple";
            center_alignment = true;
            infinite_scroll = true;
            query_in_title = true;
            hotkeys = "vim";
            results_on_new_tab = false;
          };

          outgoing = {
            request_timeout = 3.0;
            max_request_timeout = 10.0;
            pool_connections = 100;
            pool_maxsize = 20;
            enable_http2 = true;
          };

          enabled_plugins = [
            "Basic Calculator"
            "Hash plugin"
            "Hostnames plugin"
            "Open Access DOI rewrite"
            "Self Information"
            "Tracker URL remover"
            "Unit converter plugin"
          ];

          engines = [
            {
              name = "ahmia";
              disabled = true;
            }
            {
              name = "torch";
              disabled = true;
            }
          ];
        };

        faviconsSettings = {
          favicons = {
            cfg_schema = 1;
            cache = {
              db_url = "/var/cache/searx/faviconcache.db";
              HOLD_TIME = 5184000;
              LIMIT_TOTAL_BYTES = 2147483648;
              BLOB_MAX_BYTES = 40960;
              MAINTENANCE_MODE = "auto";
              MAINTENANCE_PERIOD = 600;
            };
          };
        };

        limiterSettings = {
          botdetection = {
            ipv4_prefix = 32;
            ipv6_prefix = 48;
            trusted_proxies = [
              "127.0.0.0/8"
              "::1"
            ];

            ip_lists = {
              pass_ip = [
                "192.168.0.0/16"
              ];
              pass_searxng_org = true;
            };
          };
        };
      };

      nginx.virtualHosts."search.myles.onl" = {
        useACMEHost = "myles.onl";
        forceSSL = true;
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/searx 0700 root root - -"
      "d /var/cache/searx 0750 searx searx - -"
    ];

    systemd.services = {
      searx-secret = {
        description = "Generate SearXNG secret key";
        before = ["searx-init.service"];
        requiredBy = ["searx-init.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          set -euo pipefail

          install -d -m 0700 /var/lib/searx
          if [ ! -s /var/lib/searx/searx.env ]; then
            umask 0077
            ${pkgs.coreutils}/bin/printf 'SEARX_SECRET_KEY=' > /var/lib/searx/searx.env
            ${pkgs.coreutils}/bin/head -c 48 /dev/urandom \
              | ${pkgs.coreutils}/bin/base64 --wrap=0 \
              >> /var/lib/searx/searx.env
            ${pkgs.coreutils}/bin/printf '\n' >> /var/lib/searx/searx.env
          fi
          chmod 0600 /var/lib/searx/searx.env
        '';
      };

      searx-init = {
        after = ["searx-secret.service"];
        requires = ["searx-secret.service"];
        postStart = ''
          ${pkgs.coreutils}/bin/ln -sf /etc/searxng/limiter.toml /run/searx/limiter.toml
          ${pkgs.coreutils}/bin/ln -sf /etc/searxng/favicons.toml /run/searx/favicons.toml
        '';
      };
    };
  };
}
