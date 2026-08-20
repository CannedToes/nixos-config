{
  self,
  inputs,
  ...
}: let
  subdomains = import ../../modules/_subdomains.nix;
in {
  flake.nixosConfigurations.server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = with self.nixosModules; [
      # -- disko --
      inputs.disko.nixosModules.default
      ./_disko.nix

      # -- system --
      locale
      nix
      networking
      sops

      # -- services --
      avahi
      calibreWebAutomated
      copyparty
      ddclient
      degoog
      flaresolverr
      homeAssistant
      jellyfin
      mealie
      navidrome
      nginx
      ntfy
      vaultwarden

      # -- host config --
      ({
        pkgs,
        config,
        ...
      }: {
        hardware.facter.reportPath = ./facter.json;
        sops.defaultSopsFile = ./secrets.yaml;

        hardware.enableRedistributableFirmware = true;

        hardware.graphics.enable = true;
        hardware.graphics.enable32Bit = true;
        hardware.graphics.extraPackages = [
          pkgs.intel-media-driver
          pkgs.vpl-gpu-rt
        ];

        users.users.jellyfin.extraGroups = [
          "render"
          "video"
        ];

        networking = {
          hostName = "server";
          interfaces.eth0.macAddress = "1c:69:7a:d9:e0:75";
          hosts."127.0.0.1" = subdomains;
        };

        programs.git.enable = true;

        users.groups.media = {
          gid = 1001;
        };

        users.users.media = {
          uid = 1001;
          group = "media";
          home = "/var/lib/media";
          createHome = true;
          isSystemUser = true;
        };

        boot = {
          loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
            systemd-boot.configurationLimit = 10;
          };

          kernelParams = [
            "quiet"
            "loglevel=3"
            "rd.systemd.show_status=false"
            "rd.udev.log_level=3"
            "nowatchdog"
            "tsc=reliable"
            "i915.enable_guc=3"
          ];

          initrd.systemd.enable = true;
          initrd.verbose = false;

          kernel.sysctl = {
            "vm.swappiness" = 10;
            "vm.vfs_cache_pressure" = 50;
            "kernel.sched_mingration_cost_ns" = 5000000;
            "kernel.sched_autogroup_enabled" = 0;
            "net.core.rmem_max" = 16777216;
            "net.core.wmem_max" = 16777216;
          };

          kernelPackages = pkgs.linuxPackages_zen;
        };

        sops.secrets."smb/username" = {};
        sops.secrets."smb/password" = {};

        sops.templates."smb-credentials" = {
          content = ''
            username=${config.sops.placeholder."smb/username"}
            password=${config.sops.placeholder."smb/password"}
          '';
        };

        fileSystems."/srv/storage" = {
          device = "//192.168.1.152/data";
          fsType = "cifs";
          options = [
            "credentials=${config.sops.templates."smb-credentials".path}"
            "uid=1001"
            "gid=1001"
            "file_mode=0660"
            "dir_mode=0770"
            "iocharset=utf8"
            "vers=3.1.1"
            "cache=loose"
            "noatime"
            "actimeo=60"
            "noperm"
            "_netdev"
            "x-systemd.automount"
          ];
        };

        powerManagement = {
          cpuFreqGovernor = "performance";
        };

        networking.useNetworkd = true;

        zramSwap = {
          enable = true;
          memoryPercent = 50;
          algorithm = "lz4";
        };
      })
    ];
  };

  perSystem = {...}: {
    packages.server = self.nixosConfigurations.server.config.system.build.toplevel;
  };
}
