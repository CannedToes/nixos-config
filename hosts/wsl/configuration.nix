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

        networking = {
          hostName = "wsl";
          nameservers = lib.mkForce [];
        };

        wsl = {
          enable = true;
          defaultUser = "myles";
          startMenuLaunchers = true;
          wslConf = {
            automount.enabled = false;
            interop.appendWindowsPath = true;
            network.generateResolvConf = true;
          };
        };

        nix.settings = {
          max-jobs = 8;
          auto-optimise-store = lib.mkForce false;
        };

        hardware.graphics.enable = true;

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
