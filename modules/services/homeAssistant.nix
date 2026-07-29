{...}: {
  flake.nixosModules.homeAssistant = {pkgs, ...}: {
    services.home-assistant = {
      enable = true;

      extraComponents = [
        "analytics"
        "google_translate"
        "isal"
        "met"
        "radio_browser"
        "shopping_list"
      ];

      config = {
        default_config = {};
        http = {
          server_host = "127.0.0.1";
          trusted_proxies = [
            "127.0.0.1"
            "::1"
          ];
          use_x_forwarded_for = true;
        };
      };
    };

    services.nginx.virtualHosts."home.myles.onl" = {
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
}
