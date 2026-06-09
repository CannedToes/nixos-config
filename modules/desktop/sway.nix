{...}: {
  flake.nixosModules.sway = {pkgs, ...}: {
    programs.sway = {
      enable = true;
      xwayland.enable = true;
      extraPackages = [];
    };

    services = {
      displayManager = {
        defaultSession = "sway";
        ly = {
          enable = true;
          x11Support = false;
          settings = {
            load = false;
            save = false;
          };
        };
      };
      xserver.enable = false;
    };

    environment = {
      sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
        SDL_VIDEODRIVER = "wayland";
        XDG_CURRENT_DESKTOP = "sway";
        XDG_SESSION_DESKTOP = "sway";
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };

      systemPackages = with pkgs; [
        brightnessctl
        foot
        fuzzel
        grim
        libnotify
        mako
        slurp
        swayidle
        swaylock
        wireplumber
        wl-clipboard
      ];
    };
  };
}
