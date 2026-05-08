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
      };
    };
  };
}
