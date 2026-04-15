{ self, inputs, ... }: {

  flake.nixosModules.xfce = { pkgs, lib, ... }: {
    services.xserver.enable = true;
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.desktopManager.xfce.enable = true;
  };

}
