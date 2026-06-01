{
  self,
  inputs,
  username,
  lib,
  ...
}: {
  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs username;};

    modules = with self.nixosModules; [
      # -- system --
      locale
      networking
      nix
      sops
      users

      # -- programs --
      cli
      git
      neovim

      # -- services --
      beets
      jellyfin
      navidrome
      plex
      podman
      prowlarr
      qbittorrent
      radarr
      recyclarr
      sonarr

      # -- wsl --
      inputs.nixos-wsl.nixosModules.default

      # -- home manager --
      {
        home-manager.users.${username} = {
          imports = with self.homeModules; [common];
        };
      }

      # -- host configuration --
      {
        sops.defaultSopsFile = ./secrets.yaml;

        networking.hostName = "wsl";

        wsl = {
          enable = true;
          defaultUser = username;
          useWindowsDriver = true;
          startMenuLaunchers = true;
          wslConf = {
            automount.enabled = false;
            interop.appendWindowsPath = true;
            network.generateResolvConf = false;
          };
        };

        nix.settings = {
          max-jobs = 8;
          max-substitution-jobs = 8;
          auto-optimise-store = lib.mkForce false;
        };

        hardware.graphics = {
          enable = true;
          enable32Bit = true;
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
            "uid=1000"
            "gid=1500"
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
