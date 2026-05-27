{
  self,
  inputs,
  username,
  ...
}: {
  flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs username;};

    modules = with self.nixosModules;
    with inputs.nixos-hardware.nixosModules; [
      # -- disko disk --
      # inputs.disko.nixosModules.default
      # ./disko.nix
      ./hardware.nix

      # -- system --
      locale
      networking
      nix
      sops
      users

      # -- desktop --
      audio
      bluetooth
      creative
      firefox
      fonts
      gaming
      media
      netbeans
      networkManager
      plasma
      printing

      # -- programs --
      cli
      emacs
      git
      neovim

      # -- services--
      avahi

      # -- home-manager --
      {
        home-manager.users.${username} = {
          imports = with self.homeModules; [
            common
            laptop
          ];
        };
      }

      # -- host-specific settings --
      ({pkgs, ...}: {
        sops.defaultSopsFile = ./secrets.yaml;
        hardware.facter.reportPath = ./facter.json;

        boot = {
          kernelPackages = pkgs.linuxPackages_zen;

          consoleLogLevel = 0;
          initrd.verbose = false;

          plymouth = {
            enable = true;
            theme = "breeze";
          };

          loader = {
            efi = {
              canTouchEfiVariables = true;
              efiSysMountPoint = "/boot";
            };
            grub = {
              enable = true;
              device = "nodev";
              efiSupport = true;
              gfxmodeEfi = "1366x768";
              gfxpayloadEfi = "keep";
              theme = "${pkgs.kdePackages.breeze-grub}/grub/themes/breeze";
              useOSProber = true;
            };
            timeout = 1;
          };

          kernelParams = [
            "amd_pstate=active"
            "boot.shell_on_fail"
            "drm_kms_helper.poll=0"
            "fsck.mode=auto"
            "fsck.repair=yes"
            "loglevel=3"
            "quiet"
            "rd.systemd.show_status=false"
            "rd.udev.log_level=3"
            "splash"
            "udev.log_priority=3"
            "vt.global_cursor_default=0"
          ];
          supportedFilesystems = ["ntfs"];
        };

        networking.hostName = "laptop";

        services.power-profiles-daemon.enable = false;
        services.tlp.enable = false;
        services.upower.enable = true;
        environment.variables = {
          VDPAU_DRIVER = "radeonsi";
          LIBVA_DRIVER_NAME = "radeonsi";
        };
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };

        nix.settings.max-jobs = 8;

        # these settings are for me dw abt it lil bruh
        # if you want to just run the virtual machine in a window on linux run this command
        # QEMU_OPTIONS="-display gtk" nix run .#laptop-vm
        virtualisation.vmVariant = {
          virtualisation = {
            memorySize = 4096;
            cores = 4;
            qemu.options = ["-display" "vnc=:0"];
          };
        };
      })
    ];
  };

  perSystem = {self', ...}: {
    packages.laptop = self.nixosConfigurations.laptop.config.system.build.toplevel;
    packages.laptop-vm = self.nixosConfigurations.laptop.config.system.build.vm;
  };
}
