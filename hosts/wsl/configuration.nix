{
  self,
  inputs,
  lib,
  ...
}: {
  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = with self.nixosModules; [
      # -- system --
      locale
      networking
      nix
      sops
      users

      # -- programs --
      beets
      cli
      development
      git
      neovim

      # -- services --
      navidrome
      nixarr

      # -- wsl --
      inputs.nixos-wsl.nixosModules.default

      # -- host configuration --
      {
        sops.defaultSopsFile = ./secrets.yaml;

        networking.hostName = "wsl";

        networking.resolvconf.enable = false;

        boot.kernel.sysctl = {
          "vm.vfs_cache_pressure" = 200;
          "vm.dirty_ratio" = 10;
          "vm.dirty_background_ratio" = 5;
          "vm.swappiness" = 10;
        };

        environment.etc."resolv.conf".text = ''
          nameserver 9.9.9.9
          nameserver 1.1.1.1
          options edns0
        '';

        wsl = {
          enable = true;
          defaultUser = "myles";
          startMenuLaunchers = true;
          wslConf = {
            automount.enabled = false;
            interop.appendWindowsPath = true;
            network.generateResolvConf = false;
          };
        };

        nix.settings = {
          max-jobs = 8;
          auto-optimise-store = lib.mkForce false;
        };

        hardware.graphics.enable = true;

        systemd.services = {
          transmission.serviceConfig = {
            MemoryMax = "512M";
            MemoryHigh = "256M";
          };
          jellyfin.serviceConfig = {
            MemoryMax = "2G";
            MemoryHigh = "1G";
          };
          sonarr.serviceConfig = {
            MemoryMax = "1G";
            MemoryHigh = "768M";
          };
          radarr.serviceConfig = {
            MemoryMax = "1G";
            MemoryHigh = "768M";
          };
          prowlarr.serviceConfig = {
            MemoryMax = "768M";
            MemoryHigh = "512M";
          };
          lidarr.serviceConfig = {
            MemoryMax = "768M";
            MemoryHigh = "512M";
          };
          seerr.serviceConfig = {
            MemoryMax = "768M";
            MemoryHigh = "512M";
          };
          bazarr.serviceConfig = {
            MemoryMax = "512M";
            MemoryHigh = "256M";
          };
          navidrome.serviceConfig = {
            MemoryMax = "256M";
            MemoryHigh = "128M";
          };
          audiobookshelf.serviceConfig = {
            MemoryMax = "256M";
            MemoryHigh = "128M";
          };
          shelfmark.serviceConfig = {
            MemoryMax = "256M";
            MemoryHigh = "128M";
          };
          "flaresolverr-rs".serviceConfig = {
            MemoryMax = "2G";
            MemoryHigh = "1G";
          };
        };

        fileSystems."/mnt/c" = {
          device = "C:";
          fsType = "drvfs";
          options = [
            "metadata"
            "uid=1000"
            "gid=100"
            "umask=022"
            "noatime"
          ];
        };

        fileSystems."/srv/storage" = {
          device = "D:";
          fsType = "drvfs";
          options = [
            "metadata"
            "uid=0"
            "gid=169"
            "umask=002"
            "noatime"
          ];
        };
      }
    ];
  };

  perSystem = {...}: {
    packages.wsl = self.nixosConfigurations.wsl.config.system.build.toplevel;
  };
}
