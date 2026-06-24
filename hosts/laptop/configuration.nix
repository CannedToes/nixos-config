{
  self,
  inputs,
  ...
}: let
  subdomains = import ../../modules/_subdomains.nix;
in {
  flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = with self.nixosModules;
    with inputs.nixos-hardware.nixosModules; [
      # -- hardware scan --
      ./_hardware-configuration.nix

      # -- system --
      boot
      locale
      networking
      nix
      sops
      users

      # -- desktop --
      audio
      bluetooth
      calculator
      creative
      desktopPortal
      fileManager
      firefox
      zen
      fonts
      gaming
      media
      netbeans
      networkManager
      session
      sway
      theming
      printing
      viewers

      # -- programs --
      cli
      development
      emacs
      git
      neovim

      # -- services --
      avahi

      # -- host-specific settings --
      ({pkgs, ...}: {
        sops.defaultSopsFile = ./secrets.yaml;
        hardware.facter.reportPath = ./facter.json;

        boot = {
          kernelPackages = pkgs.linuxPackages_zen;
          consoleLogLevel = 3;
          initrd.verbose = false;
          loader.grub.gfxmodeEfi = "1366x768";
          loader.timeout = 1;
          kernelParams = [
            "amd_pstate=active"
            "quiet"
            "splash"
            "loglevel=3"
            "rd.systemd.show_status=false"
            "rd.udev.log_level=3"
            "udev.log_priority=3"
            "vt.global_cursor_default=0"
            "fsck.mode=auto"
            "fsck.repair=yes"
          ];
        };

        networking.hostName = "laptop";

        networking.hosts."192.168.1.158" = subdomains;

        services = {
          tlp = {
            enable = true;
            settings = {
              CPU_BOOST_ON_AC = 1;
              CPU_BOOST_ON_BAT = 0;
              CPU_DRIVER_OPMODE_ON_AC = "active";
              CPU_DRIVER_OPMODE_ON_BAT = "active";
              CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
              CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
              CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
              CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
              RUNTIME_PM_ON_AC = "on";
              RUNTIME_PM_ON_BAT = "auto";
              USB_AUTOSUSPEND = 1;
              WIFI_PWR_ON_AC = "off";
              WIFI_PWR_ON_BAT = "on";
            };
          };
        };

        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };

        nix.settings.max-jobs = 8;

        virtualisation.vmVariant = {
          services.spice-vdagentd.enable = true;

          virtualisation = {
            diskImage = "./laptop-impermanence.qcow2";
            memorySize = 4096;
            cores = 4;
            qemu.options = [
              "-spice"
              "addr=127.0.0.1,port=5930,disable-ticketing=on"

              "-vga"
              "qxl"

              "-device"
              "virtio-serial-pci"
              "-chardev"
              "spicevmc,id=spicechannel0,name=vdagent"
              "-device"
              "virtserialport,chardev=spicechannel0,name=com.redhat.spice.0"
            ];
          };
        };
      })
    ];
  };

  perSystem = {...}: {
    packages.laptop = self.nixosConfigurations.laptop.config.system.build.toplevel;
    packages.laptop-vm = self.nixosConfigurations.laptop.config.system.build.vm;
  };
}
