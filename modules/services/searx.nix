{...}: {
  flake.nixosModules.searx = {config, ...}: {
    sops.secrets.searx = {};

    services.searx = {
      enable = true;

      configureNginx = true;
      domain = "search.myles.onl";

      environmentFile = config.sops.secrets.searx.path;

      redisCreateLocally = true;

      settings = {
        use_default_settings = true;

        general = {
          instance_name = "search.myles.onl";
        };

        server = {
          secret_key = "$SECRET_KEY";
          method = "GET";
          image_proxy = true;
        };

        ui = {
          default_locale = "en";
          hotkeys = "vim";
          url_formatting = "pretty";
          theme_args.simple_style = "auto";
        };

        plugins."searx.plugins.infinite_scroll.SXNGPlugin".active = true;

        search = {
          safe_search = 0;
          autocomplete = "duckduckgo";
          autocomplete_min = 4;
          default_lang = "en";
          suspended_times = {
            SearxEngineTooManyRequests = 600;
            SearxEngineCaptcha = 3600;
          };
        };

        engines = [
          {
            name = "duckduckgo";
            engine = "duckduckgo";
            shortcut = "ddg";
            disabled = false;
          }
          {
            name = "google";
            engine = "google";
            shortcut = "go";
            disabled = false;
          }
          {
            name = "brave";
            engine = "brave";
            shortcut = "bv";
            disabled = false;
          }
          {
            name = "startpage";
            engine = "startpage";
            shortcut = "sp";
            disabled = true;
          }
          {
            name = "wikipedia";
            engine = "wikipedia";
            shortcut = "wp";
            disabled = false;
          }
        ];
      };

      limiterSettings = {
        real_ip = {
          x_for = 1;
          ipv4_prefix = 32;
          ipv6_prefix = 56;
        };
      };
    };

    services.nginx = {
      virtualHosts."search.myles.onl" = {
        useACMEHost = "myles.onl";
        forceSSL = true;
      };
    };
  };
}
