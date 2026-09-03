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
      waydroid
      waydroidAtv

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

        environment.systemPackages = with pkgs; [
          curl
        ];

        services.logind.settings.Login.HandleLidSwitch = "ignore";

        services.getty.autologinUser = "myles";

        systemd.user.services.waydroid-kiosk = {
          description = "Waydroid Android TV kiosk";
          wantedBy = ["default.target"];
          serviceConfig = {
            ExecStart = ''
              ${pkgs.bash}/bin/bash -c 'for i in $(seq 1 60); do ${pkgs.waydroid-nftables}/bin/waydroid shell echo ok >/dev/null 2>&1 && break; sleep 5; done; exec ${pkgs.cage}/bin/cage -m last ${pkgs.waydroid-nftables}/bin/waydroid show-full-ui'
            '';
            Restart = "on-failure";
            RestartSec = "5";
          };
        };

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
      })
    ];
  };

  perSystem = {...}: {
    packages.htpc = self.nixosConfigurations.htpc.config.system.build.toplevel;
    packages.htpc-images = self.nixosConfigurations.htpc.config.waydroidAtv.images;
  };
}
