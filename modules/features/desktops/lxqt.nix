{ self, inputs, ... }: {

  flake.nixosModules.lxqt = { pkgs, lib, ... }: {
    services.xserver.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.lxqt.enable = true;
  };

}
