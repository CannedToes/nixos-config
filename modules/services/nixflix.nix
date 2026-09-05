{inputs, ...}: {
  flake.nixosModules.nixflix = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      inputs.nixflix.nixosModules.default
    ];

    services.caddy.package = lib.mkIf (config.nixflix.enable && config.nixflix.caddy.enable) (
      lib.mkForce (
        pkgs.caddy.withPlugins {
          plugins = [ "github.com/caddyserver/replace-response@v0.0.0-20250618171559-80962887e4c6" ];
          hash = "sha256-2tcvl9ZDpe7SAy3tZCPNwmw0KoIIakqggVaRtVAg9R0=";
        }
      )
    );

    sops.secrets = {
      "sonarr/api_key" = {};
      "sonarr/password" = {};

      "radarr/api_key" = {};
      "radarr/password" = {};

      "prowlarr/api_key" = {};
      "prowlarr/password" = {};

      "jellyfin/api_key" = {};
      "jellyfin/myles_password" = {};
      "jellyfin/family_password" = {};
      "jellyfin/malachite_password" = {};
    };

    nixflix = {
      enable = true;
      mediaDir = "/srv/storage/media";
      downloadsDir = "/srv/storage/downloads";
      mediaUsers = ["myles"];

      theme = {
        enable = true;
        name = "catpuccin-latte";
      };

      caddy = {
        enable = true;
        addHostsEntries = true;
        domain = "myles.onl";
        tls = {
          enable = true;
          acmeEmail = "mylesglanville@gmail.com";
        };
      };

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

      recyclarr = {
        enable = true;
        # cleanupUnmanagedProfiles = true;
      };

      jellyfin = {
        enable = true;
        apiKey = {_secret = config.sops.secrets."jellyfin/api_key".path;};
        users = {
          myles = {
            mutable = false;
            policy.isAdministrator = true;
            password._secret = config.sops.secrets."jellyfin/myles_password".path;
          };
          family = {
            mutable = false;
            password._secret = config.sops.secrets."jellyfin/family_password".path;
          };
          malachite = {
            mutable = false;
            password._secret = config.sops.secrets."jellyfin/malachite_password".path;
          };
        };
      };
    };
  };
}
