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
    };
  };
}
