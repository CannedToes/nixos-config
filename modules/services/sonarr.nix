<<<<<<< HEAD
{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.sonarr = {
    pkgs,
    lib,
    config,
    ...
  }: {
    services.sonarr = {
      enable = true;
      openFirewall = true;
      environmentFiles = config.sops.secrets.sonarr.path;
||||||| (empty tree)
=======
{...}: {
  flake.nixosModules.sonarr = {config, ...}: {
    sops.secrets.sonarr = {};

    services.sonarr = {
      enable = true;
      openFirewall = true;
      environmentFiles = [config.sops.secrets.sonarr.path];
    };

    users.users.sonarr.extraGroups = ["media"];

    systemd.services.sonarr = {
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
>>>>>>> 8a283fc (GINEMINANORMOUS REFACTOR)
    };
  };
}
