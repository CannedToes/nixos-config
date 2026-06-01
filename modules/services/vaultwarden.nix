{...}: {
  flake.nixosModules.vaultwarden = {config, ...}: {
    sops.secrets.vaultwarden = {};

    services.vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      configurePostgres = true;

      environmentFile = config.sops.secrets.vaultwarden.path;

      config = {
        DOMAIN = "https://vault.myles.onl";
        SIGNUPS_ALLOWED = false;

        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;

        WEBSOCKET_ENABLED = true;

        PUSH_ENABLED = true;
        PUSH_RELAY_URI = "https://api.bitwarden.eu";
        PUSH_IDENTITY_URI = "https://identity.bitwarden.eu";
      };
    };

    services.nginx.virtualHosts."vault.myles.onl" = {
      useACMEHost = "myles.onl";
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:8222";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_request_buffering off;
        '';
      };
    };
  };
}
