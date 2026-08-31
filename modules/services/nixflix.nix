{...}: {
  flake.nixosModules.nixflix = {config, ...}: {
    nixflix = {
      enable = true;
      mediaDir = "/srv/storage/media";
      stateDir = "/var/lib/nixflix";

      caddy.enable = true;
      postgres.enable = true;

      sonarr = {
        enable = true;
        config = {
          apiKey = {_secret = config.sops.secrets."sonarr/api_key".path;};
          hostConfig.password = {_secret = config.sops.secrets."sonarr/password".path;};
        };
      };

      radarr = {
        enable = true;
        config = {
          apiKey = {_secret = config.sops.secrets."radarr/api_key".path;};
          hostConfig.password = {_secret = config.sops.secrets."radarr/password".path;};
        };
      };

      prowlarr = {
        enable = true;
        config = {
          apiKey = {_secret = config.sops.secrets."prowlarr/api_key".path;};
          hostConfig.password = {_secret = config.sops.secrets."prowlarr/password".path;};
        };
      };
    };
  };
}
