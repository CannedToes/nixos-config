<<<<<<< HEAD
{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.ddclient = {
    pkgs,
    lib,
    config,
    ...
  }: {
    services.ddclient = {
      enable = true;
      interval = "5min";
      protocol = "cloudflare";
      username = "token";
      passwordFile = config.sops.secrets."ddclient/cloudflare".path;
      domains = ["myles.onl"];
      zone = "myles.onl";
      ssl = true;
    };
||||||| (empty tree)
=======
{...}: {
  flake.nixosModules.ddclient = {config, ...}: {
    services.ddclient = {
      enable = true;
      interval = "5m";

      protocol = "cloudflare";
      username = "token";
      passwordFile = config.sops.secrets."ddclient/cloudflare".path;
      domain = "myles.onl";
      zone = "myles.onl";

      ssl = true;
    };

    sops.secrets."ddclient/cloudflare" = {};
>>>>>>> 8a283fc (GINEMINANORMOUS REFACTOR)
  };
}
