{ self, inputs, ... }: {

  flake.nixosModules.lxqt = { pkgs, lib, config, ... }: {
    imports = [
      self.nixosModules.desktop
    ];
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.displayManager.sessionPackages = [ pkgs.lxqt.lxqt-wayland-session ];

    services.xserver.desktopManager.lxqt.enable = true;
    environment.systemPackages = with pkgs; [
      lxqt.lxqt-wayland-session
      bibata-cursors
      papirus-icon-theme
      labwc
      xwayland
    ];

    xdg.portal = {
      enable = true;
      wlr.enable = true;
    };

    qt = {
      enable = true;
      platformTheme = "lxqt";
    };
  };

}
