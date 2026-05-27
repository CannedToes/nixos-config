<<<<<<< HEAD
{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.ntfy = {
    pkgs,
    lib,
    config,
    ...
  }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];
    # shhhhhhhhhh
    sops.secrets.ntfy = {};
    # postgres db
    services.postgresql = {
      enable = true;
      ensureDatabases = ["ntfy-sh"];
      ensureUsers = [
        {
          name = "ntfy-sh";
          ensureDBOwnership = true;
        }
      ];
    };
    # setting up the ntfy service itself (i have to lib.mkForce because the current upstream ntfy-sh service defaults are broken)
    services.ntfy-sh = {
      enable = true;
      environmentFile = config.sops.secrets.ntfy.path;
      settings = lib.mkForce {
        # server
        listen-http = ":3492";
        base-url = "https://ntfy.myles.onl";
        behind-proxy = true;

        # database
        database-url = "postgres://@/ntfy-sh";

        # access control
        auth-default-access = "deny-all";
        enable-login = true;
        require-login = true;

        # upstream (FUCK YOU APPLE)
        upstream-base-url = "https://ntfy.sh";
      };
    };
    # reverse proxy with nginx
    services.nginx = {
      virtualHosts."ntfy.myles.onl" = {
        useACMEHost = "myles.onl";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3492";
          proxyWebsockets = true;
        };
||||||| (empty tree)
=======
{...}: {
  flake.nixosModules.ntfy = {...}: {
    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://ntfy.myles.onl";
        listen-http = "0.0.0.0:2586";
        behind-proxy = true;
        cache-file = "/var/lib/ntfy-sh/cache.db";
        attachment-cache-dir = "/var/lib/ntfy-sh/attachments";
        auth-file = "/var/lib/ntfy-sh/user.db";
        auth-default-access = "deny-all";
      };
    };

    services.nginx.virtualHosts."ntfy.myles.onl" = {
      useACMEHost = "myles.onl";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:2586";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_redirect off;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
>>>>>>> 8a283fc (GINEMINANORMOUS REFACTOR)
      };
    };
  };
}
