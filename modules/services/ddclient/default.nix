{ self, inputs, ... }: {
  flake.nixosModules.ddclient = { pkgs, lib, config, ... }: {
    services.ddclient = {
      enable = true;
      interval = "5min";
      protocol = "cloudflare";
      username = "token";
      passwordFile = config.sops.secrets."ddclient/cloudflare".path;
      domains = [ "myles.onl" ];
      zone = "myles.onl";
      ssl = true;
    };
  };
}
