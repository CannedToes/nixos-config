{
  self,
  inputs,
  username,
  ...
}: {
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs username;};

    modules = with self.nixosModules; [
      # -- system --
      locale
      nix
      networking
      sops
      users

      # -- hardware --
      nvidia
      amd

      # -- desktop --
      audio
      bluetooth
      creative
      firefox
      fonts
      media
      noctalia
      plasma
      printing
      gaming

      # -- programs --
      cli
      emacs
      git
      neovim

      # -- services --
      # avahi
      # podman
      # navidrome
      # sonarr
      # radarr
      # prowlarr
      # recyclarr
      # jellyseerr
      # plex
      # jellyfin
      # beets
      # qbittorrent

      # -- home-manager --
      {
        home-manager.users.${username} = {
          imports = [
            self.homeModules.common
            self.homeModules.desktop
          ];
        };
      }

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
