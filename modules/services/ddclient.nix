{...}: {
  flake.nixosModules.ddclient = {config, ...}: {
    sops.secrets."ddclient/cloudflare" = {};

    services.ddclient = {
      enable = true;
      interval = "5m";

      protocol = "cloudflare";
      username = "token";
      passwordFile = config.sops.secrets."ddclient/cloudflare".path;
      domains = ["myles.onl"];
      zone = "myles.onl";

      ssl = true;
    };
  };
}
