{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = with self.nixosModules; [
      # -- system --
      locale
      networking
      nix
      sops
      users

      # -- hardware --
      amd
      nvidia

      # -- desktop --
      audio
      bluetooth
      creative
      firefox
      fonts
      gaming
      media
      printing
      sway

      # -- programs --
      beets
      cli
      emacs
      git
      neovim

      # -- services --
      # avahi
      # jellyfin
      # jellyseerr
      # navidrome
      # plex
      # prowlarr
      # qbittorrent
      # radarr
      # recyclarr
      # sonarr

      # -- host-specific settings --
      ({pkgs, ...}: {
        sops.defaultSopsFile = ./secrets.yaml;

        nixpkgs.overlays = [inputs.nix-cachyos-kernel.overlays.pinned];
        boot = {
          plymouth = {
            enable = true;
            theme = "breeze";
          };

          loader = {
            efi.canTouchEfiVariables = true;
            efi.efiSysMountPoint = "/boot";
            grub = {
              enable = true;
              efiSupport = true;
              device = "nodev";
              useOSProber = true;
              gfxmodeEfi = "1920x1080";
              gfxpayloadEfi = "keep";
            };
          };

          kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
          kernelParams = ["quiet" "splash" "nvidia-drm.modeset=1"];
          supportedFilesystems = ["ntfs"];
        };

        networking.hostName = "desktop";

        virtualisation.vmVariant = {
          virtualisation = {
            memorySize = 8192;
            cores = 6;
            qemu.options = ["-display" "vnc=:0"];
          };
        };

        nix.settings.max-jobs = 12;
      })
    ];
  };

  perSystem = {...}: {
    packages.desktop = self.nixosConfigurations.desktop.config.system.build.toplevel;
    packages.desktop-vm = self.nixosConfigurations.desktop.config.system.build.vm;
  };
}
