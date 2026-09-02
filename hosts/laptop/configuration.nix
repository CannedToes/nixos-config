{
  self,
  inputs,
  ...
}: let
  subdomains = import ../../modules/_subdomains.nix;
in {
  flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = with self.nixosModules; [
      # -- hardware scan --
      ./_hardware-configuration.nix

      # -- system --
      boot
      kernel
      locale
      networking
      nix
      sops
      users

      # -- hardware --
      graphics

      # -- desktop --
      audio
      bluetooth
      fonts
      gaming
      gnome
      media
      zen
      waydroid

      # -- programs --
      cli
      dev
      emacs

      # -- services --
      avahi

      # -- host-specific settings --
      ({pkgs, ...}: {
        services.printing.enable = true;
        networking.networkmanager.enable = true;

        sops.defaultSopsFile = ./secrets.yaml;
        hardware.facter.reportPath = ./facter.json;

        boot = {
          kernelPackages = pkgs.linuxPackages_zen;
          consoleLogLevel = 3;
          loader.grub.gfxmodeEfi = "1366x768";
          loader.timeout = 1;
          kernelParams = [
            "amd_pstate=active"
            "splash"
            "vt.global_cursor_default=0"
            "fsck.mode=auto"
            "fsck.repair=yes"
          ];
        };

        networking.hostName = "laptop";

        networking.hosts."192.168.1.158" = subdomains;

        nix.settings.max-jobs = 8;
      })
    ];
  };
}
