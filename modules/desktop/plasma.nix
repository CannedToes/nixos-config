# -- Plasma 6 desktop environment --
{...}: {
  flake.nixosModules.plasma = {pkgs, ...}: let
    papirusFolderColor = "palebrown";
  in {
    services.desktopManager.plasma6.enable = true;
    services.displayManager.plasma-login-manager.enable = true;
    services.displayManager.defaultSession = "plasma";
    services.libinput.enable = true;

    environment.systemPackages = with pkgs; [
      (papirus-icon-theme.override {color = papirusFolderColor;})
    ];

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      discover
      kwin-x11
      plasma-browser-integration
      plasma-workspace-wallpapers
    ];
  };
}
