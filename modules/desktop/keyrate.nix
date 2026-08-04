{self, ...}: {
  flake.nixosModules.keyrate = {
    config,
    pkgs,
    ...
  }: {
    programs.dconf.enable = true;
  };
}
