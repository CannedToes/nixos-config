<<<<<<< HEAD
{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.vaultwarden = {
    pkgs,
    lib,
    config,
    ...
  }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];
    # shhhh
    sops.secrets.vaultwarden = {};

    # the vaultwarden service
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
        ROCKET_LOG = "critical";

        ENABLE_WEBSOCKET = true;

        PUSH_ENABLED = true;
        PUSH_RELAY_URI = "https://api.bitwarden.eu";
        PUSH_IDENTITY_URI = "https://identity.bitwarden.eu";
      };
    };

    # reverse proxy for vaultwarden
    services.nginx = {
      virtualHosts."vault.myles.onl" = {
        useACMEHost = "myles.onl";
        forceSSL = true;
        extraConfig = ''
          proxy_buffering off;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:8222";
          proxyWebsockets = true;
        };
||||||| (empty tree)
=======
{...}: {
  flake.nixosModules.vaultwarden = {config, ...}: {
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

    sops.secrets.vaultwarden = {};

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
>>>>>>> 8a283fc (GINEMINANORMOUS REFACTOR)
      };
    };
  };
}
