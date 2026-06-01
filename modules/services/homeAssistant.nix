{...}: {
  flake.nixosModules.homeAssistant = {pkgs, ...}: {
    # postgres for home assistant
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
    # home assistant config
    services.home-assistant = {
      enable = true;
      openFirewall = true;
      extraPackages = python3Packages: with python3Packages; [psycopg2];
      customComponents = with pkgs.home-assistant-custom-components; [
        localtuya
      ];
      extraComponents = [
        "apple_tv"
        "asuswrt"
        "default_config"
        "esphome"
        "google_translate"
        "homeassistant"
        "homekit"
        "isal"
        "jellyfin"
        "met"
        "mpd"
        "music_assistant"
        "ntfy"
        "plex"
        "radio_browser"
        "shopping_list"
        "yamaha_musiccast"
      ];
      config = {
        default_config = {};
        recorder.db_url = "postgresql://@/hass";
        homeassistant = {
          name = "Glanville Home";
          unit_system = "metric";
          temperature_unit = "C";
        };
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [
            "127.0.0.1"
          ];
        };
      };
    };
    # reverse proxy with nginx
    services.nginx = {
      virtualHosts."home.myles.onl" = {
        useACMEHost = "myles.onl";
        forceSSL = true;
        extraConfig = ''
          proxy_buffering off;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:8123";
          proxyWebsockets = true;
        };
      };
    };
  };
}
