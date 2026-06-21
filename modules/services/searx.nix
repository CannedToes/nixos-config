{ ... }: {
  flake.nixosModules.searx = { config, ... }: {
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
          public_instance = true;
          limiter = true;
          image_proxy = true;
          method = "GET";
        };

        ui = {
          default_locale = "en";
        };

        search = {
          # formats = [ "html" ];
          safe_search = 0;
          autocomplete = "duckduckgo";
        };
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
