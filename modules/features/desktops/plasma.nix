{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.plasma = {
    pkgs,
    lib,
    config,
    ...
  }: {
    imports = [
      self.nixosModules.desktop
    ];
    services.desktopManager.plasma6.enable = true;
    services.displayManager.plasma-login-manager.enable = true;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      discover
      kwin-x11
      plasma-browser-integration
      plasma-workspace-wallpapers
    ];
  };
}
