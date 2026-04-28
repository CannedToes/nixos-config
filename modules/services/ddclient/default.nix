{ self, inputs, ... }: {
  flake.nixosModules.ddclient = { pkgs, lib, ... }: {
    services.ddclient = {
      enable = true;
      interval = "5min";
      protocol = "cloudflare";
      username = "token";
    };
  };
}
