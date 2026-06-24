{
  self,
  inputs,
  ...
}: let
  subdomains = import ../../modules/_subdomains.nix;
in {
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = with self.nixosModules; [
      # -- system --
      boot
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
      development
      emacs
      git
      neovim

      # -- services --
      navidrome
      nixarr

      # -- host-specific settings --
      ({pkgs, ...}: {
        sops.defaultSopsFile = ./secrets.yaml;

        nixpkgs.overlays = [inputs.nix-cachyos-kernel.overlays.pinned];
        boot = {
          plymouth.theme = "breeze";
          loader.grub.gfxmodeEfi = "1920x1080";
          kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
          kernelParams = ["quiet" "splash" "nvidia-drm.modeset=1"];
        };

        networking.hostName = "desktop";
        networking.hosts."192.168.1.158" = subdomains;

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
