{...}: {
  flake.nixosModules.plasmaBigscreen = {pkgs, ...}: let
    # plasma-bigscreen does not pull in kdeconnect-kde's Qt QML modules, which
    # its HomeScreen needs to load, so add them to the wrapped import path.
    bigscreen = pkgs.kdePackages.plasma-bigscreen.overrideAttrs (old: {
      buildInputs = (old.buildInputs or []) ++ [pkgs.kdePackages.kdeconnect-kde];
      preFixup =
        (old.preFixup or "")
        + ''
          wrapQtApp $out/bin/plasma-bigscreen-wayland \
            --prefix QML2_IMPORT_PATH : "${pkgs.kdePackages.kdeconnect-kde}/lib/qt-6/qml"
        '';
    });
  in {
    services.desktopManager.plasma6.enable = true;

    services.displayManager = {
      sddm.enable = true;
      defaultSession = "plasma-bigscreen-wayland";
      sessionPackages = [bigscreen];
      autoLogin = {
        enable = true;
        user = "myles";
      };
    };

    xdg.portal.configPackages = [
      pkgs.kdePackages.plasma-workspace
      bigscreen
    ];
  };
}
