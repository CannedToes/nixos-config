{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = with self.nixosModules; [
      # -- system --
      locale
      networking
      nix
      sops
      users

      # -- programs --
      beets
      cli
      development
      neovim
      emacs

      # -- wslg --
      fonts
      theming
      desktopPortal
      session

      # -- services --
      navidrome
      jellyfin

      # -- wsl --
      inputs.nixos-wsl.nixosModules.default

      # -- host configuration --
      ({config, pkgs, lib, ...}: {
        sops.defaultSopsFile = ./secrets.yaml;

        networking.hostName = "wsl";

        networking.dhcpcd.enable = false;
        networking.firewall.trustedInterfaces = ["lo"];
        networking.networkmanager.enable = false;

        systemd.network.enable = false;
        systemd.services.systemd-resolved.enable = false;
        systemd.services.systemd-udevd.enable = false;

        nixpkgs.overlays = [inputs.emacs-overlay.overlays.default];

        # emacs-pgtk daemon auto-start causes Weston SIGSEGV on boot
        # due to GTK3 PGTK race condition with WSLg initialization.
        # Start manually: systemctl --user start emacs
        services.emacs.enable = lib.mkForce false;

        wsl = {
          enable = true;
          useWindowsDriver = true;
          defaultUser = "myles";
          startMenuLaunchers = true;
          wslConf = {
            automount.enabled = false;
            interop.appendWindowsPath = true;
            network.generateResolvConf = false;
          };
        };

        systemd.tmpfiles.rules = [
          "L+ /run/user/${toString config.users.users.myles.uid}/wayland-0 - - - - /mnt/wslg/runtime-dir/wayland-0"
        ];

        environment.interactiveShellInit = ''
          export PATH="$PATH:$HOME/.config/emacs/bin"
        '';

        # gui apps through wslg
        environment.systemPackages = with pkgs; [
          glib-networking
          gsettings-desktop-schemas
          libnotify
          libsoup_3
          pulseaudio
          shared-mime-info
          vulkan-loader
          wl-clipboard
          nerd-fonts.symbols-only
        ];

        fileSystems."/mnt/c" = {
          device = "C:";
          fsType = "drvfs";
          options = [
            "metadata"
            "uid=1000"
            "gid=100"
            "umask=022"
            "noatime"
          ];
        };

        fileSystems."/srv/storage" = {
          device = "D:";
          fsType = "drvfs";
          options = [
            "metadata"
            "uid=0"
            "gid=169"
            "umask=002"
            "noatime"
          ];
        };
      })
    ];
  };

  perSystem = {...}: {
    packages.wsl = self.nixosConfigurations.wsl.config.system.build.toplevel;
  };
}
