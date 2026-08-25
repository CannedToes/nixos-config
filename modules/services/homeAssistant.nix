{...}: {
  flake.nixosModules.homeAssistant = {pkgs, ...}: {
    services.postgresql = {
      enable = true;
      ensureDatabases = ["hass"];
      ensureUsers = [
        {
          name = "hass";
          ensureDBOwnership = true;
        }
      ];
    };

    services.home-assistant = {
      enable = true;
      openFirewallForComponents = true;

      lovelaceConfigFile = null;

      config = {
        default_config = {};

        recorder.db_url = "postgresql:///hass";

        homeassistant = {
          name = "My Home";
          latitude = "!secret latitude";
          longitude = "!secret longitude";
          elevation = 10;
          unit_system = "metric";
          time_zone = "Africa/Johannesburg";
        };

        http = {
          server_host = "::1";
          trusted_proxies = [
            "127.0.0.1"
            "::1"
          ];
          use_x_forwarded_for = true;
        };
      };

      extraComponents = [
        "analytics"
        "google_translate"
        "isal"
        "met"
        "homekit"
        "radio_browser"
        "shopping_list"
        "apple_tv"
        "yamaha_musiccast"
        "plex"
        "jellyfin"
        "pi_hole"
        "icloud"
        "bluetooth"
        "bluetooth_adapters"
      ];

      themes = with pkgs.home-assistant-themes; [
        material-you-theme
      ];

      customComponents = with pkgs.home-assistant-custom-components; [
        tuya_local
      ];

      extraPackages = ps:
        with ps; [
          psycopg2
        ];
    };

    services.nginx.virtualHosts."home.myles.onl" = {
      useACMEHost = "myles.onl";
      forceSSL = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://[::1]:8123";
        proxyWebsockets = true;
      };
    };
  };
}
