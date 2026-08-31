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
            timeout = 0;
          };
        };

        programs.kdeconnect.enable = true;
        programs.firefox.enable = true;

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

        environment = {
          systemPackages = with pkgs; [
            jellyfin-media-player
            mpv
            plex-desktop
            vacuum-tube
          ];
        };
      })
    ];
  };

  perSystem = {...}: {
    packages.htpc = self.nixosConfigurations.htpc.config.system.build.toplevel;
  };
}
