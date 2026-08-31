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
      kernel
      locale
      networking
      nix
      users
      zram

      # -- hardware --
      graphics

      # -- desktop --
      audio
      bluetooth
      fonts
      plasmaBigscreen

      # -- host-specific settings --
      ({
        pkgs,
        lib,
        ...
      }: {
        hardware.facter.reportPath = ./facter.json;
        networking.hostName = "htpc";
        networking.networkmanager.enable = true;

        hardware.cpu.intel.updateMicrocode = true;

        hardware.graphics.extraPackages = [
          pkgs.intel-vaapi-driver
        ];

        boot = {
          kernelPackages = pkgs.linuxPackages;
          consoleLogLevel = 3;
          kernelParams = [
            "splash"
            "nowatchdog"
            "mitigations=off"
          ];
          loader = {
            efi.canTouchEfiVariables = true;
            systemd-boot.enable = true;
            systemd-boot.configurationLimit = 10;
            timeout = 1;
          };
        };

        powerManagement.cpuFreqGovernor = "performance";

        networking.dhcpcd.enable = false;

        networking.modemmanager.enable = false;
        systemd.services.accounts-daemon.wantedBy = lib.mkForce [];
        systemd.services.accounts-daemon.enable = lib.mkForce false;
        services.power-profiles-daemon.enable = false;

        nix.optimise.automatic = true;
        nix.settings.max-jobs = 1;

        services.journald.extraConfig = "SystemMaxUse=200M";

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

        programs.kdeconnect.enable = true;

        programs.firefox.enable = true;

        services.logind.settings.Login.HandleLidSwitch = "ignore";

        systemd.user.services.htpc-hdmi-audio = {
          description = "Route audio to the HDMI (TV) output";
          wantedBy = ["default.target"];
          after = ["pipewire.service" "wireplumber.service"];
          path = [pkgs.pulseaudio];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            for i in $(seq 1 10); do
              pactl set-card-profile alsa_card.pci-0000_00_1b.0 output:hdmi-stereo && break
              sleep 1
            done
            pactl set-default-sink alsa_output.pci-0000_00_1b.0.hdmi-stereo || true
          '';
        };

        environment.etc."xdg/autostart/htpc-disable-edp.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Disable internal panel
          Exec=kscreen-doctor output.eDP-1 disable
          X-KDE-autostart-after=panel
        '';

        environment.etc."xdg/mpv/mpv.conf".text = ''
          hwdec=auto-safe
        '';

        environment = {
          sessionVariables = {
            LIBVA_DRIVER_NAME = "i965";
            NIXOS_OZONE_WL = "1";
            MOZ_ENABLE_WAYLAND = "1";
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
