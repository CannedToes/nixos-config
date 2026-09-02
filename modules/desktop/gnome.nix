{...}: {
  flake.nixosModules.gnome = {
    lib,
    pkgs,
    ...
  }: {
    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      # lord forgive me for i have sinned
      # flatpak.enable = true;
      fwupd.enable = true;

      tlp.enable = lib.mkForce false;
      gnome.gnome-keyring.enable = true;
    };

    # exclude default GNOME bloat
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      # gnome-user-docs
      epiphany # web browser
      # geary    # email client
    ];
    # add default GNOME bloat
    environment.systemPackages = with pkgs; [
      gnome-tweaks

      gnomeExtensions.appindicator
      gnomeExtensions.caffeine
      gnomeExtensions.vitals
    ];

    # system-wide dconf defaults
    programs.dconf.profiles.user.databases = [
      {
        settings = {
          "org/gnome/desktop/interface" = {
            accent-color = "purple";
            color-scheme = "prefer-dark";
            clock-show-weekday = true;
            show-battery-percentage = true;
            enable-hot-corners = false;
          };

          "org/gnome/desktop/peripherals/touchpad" = {
            tap-to-click = true;
            natural-scroll = true;
          };

          "org/gnome/mutter" = {
            edge-tiling = true;
            dynamic-workspaces = true;
            experimental-features = ["scale-monitor-framebuffer"];
          };

          "org/gnome/nautilus/preferences" = {
            default-folder-viewer = "list-view";
            show-create-link = true;
          };

          "org/gnome/shell" = {
            disable-user-extensions = false;
            enabled-extensions = [
              pkgs.gnomeExtensions.appindicator.extensionUuid
              pkgs.gnomeExtensions.caffeine.extensionUuid
              pkgs.gnomeExtensions.vitals.extensionUuid
            ];
          };
        };
      }
    ];

    # adwaita qt theming
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };
  };
}
