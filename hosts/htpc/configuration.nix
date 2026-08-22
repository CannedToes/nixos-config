{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.htpc = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = with self.nixosModules; [
      # -- disko --
      inputs.disko.nixosModules.default
      ./_disko.nix

      # -- system --
      locale
      networking
      nix
      users

      # -- desktop --
      audio
      bluetooth
      fonts
      plasmaBigscreen

      # -- host-specific settings --
      ({pkgs, ...}: {
        networking.hostName = "htpc";
        networking.networkmanager.enable = true;

        hardware.cpu.intel.updateMicrocode = true;

        hardware.graphics = {
          enable = true;
          enable32Bit = true;
          extraPackages = [
            pkgs.intel-media-driver
            pkgs.intel-compute-runtime
            pkgs.vpl-gpu-rt
          ];
        };

        boot = {
          kernelPackages = pkgs.linuxPackages_zen;
          consoleLogLevel = 3;
          initrd.verbose = false;
          kernelParams = [
            "quiet"
            "splash"
            "loglevel=3"
            "rd.systemd.show_status=false"
            "rd.udev.log_level=3"
            "udev.log_priority=3"
            "nowatchdog"
          ];
          loader = {
            efi.canTouchEfiVariables = true;
            systemd-boot.enable = true;
            systemd-boot.configurationLimit = 10;
            timeout = 1;
          };
        };

        powerManagement.cpuFreqGovernor = "powersave";

        zramSwap = {
          enable = true;
          memoryPercent = 50;
          algorithm = "lz4";
        };

        services.fwupd.enable = false;

        environment.plasma6.excludePackages = with pkgs.kdePackages; [
          ark
          aurorae
          dolphin
          elisa
          ffmpegthumbs
          gwenview
          kate
          khelpcenter
          konsole
          krdp
          kwin-x11
          okular
          plasma-browser-integration
          plasma-workspace-wallpapers
          spectacle
          union
        ];

        environment.etc."xdg/kdedefaults/baloofilerc".text = ''
          [Basic Settings]
          Indexing-Enabled=false
        '';

        xdg.portal.xdgOpenUsePortal = true;

        environment = {
          sessionVariables = {
            LIBVA_DRIVER_NAME = "iHD";
            NIXOS_OZONE_WL = "1";
          };

          systemPackages = with pkgs; [
            jellyfin-media-player
            mpv
            plex-desktop
            vacuum-tube
          ];
        };

        virtualisation.vmVariant = {
          services.spice-vdagentd.enable = true;

          virtualisation = {
            diskImage = "./htpc.qcow2";
            memorySize = 4096;
            cores = 4;
            qemu.options = [
              "-spice"
              "addr=127.0.0.1,port=5931,disable-ticketing=on"

              "-vnc"
              "127.0.0.1:5"

              "-vga"
              "qxl"

              "-global"
              "qxl-vga.xres=1920"
              "-global"
              "qxl-vga.yres=1080"
              "-global"
              "qxl-vga.vgamem_mb=64"

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
    packages.htpc = self.nixosConfigurations.htpc.config.system.build.toplevel;
    packages.htpc-vm = self.nixosConfigurations.htpc.config.system.build.vm;
  };
}
