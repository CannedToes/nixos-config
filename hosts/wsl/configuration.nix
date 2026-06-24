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

          enableIPv6 = false;
          nameservers = lib.mkForce [];
        };

        services.resolved.enable = lib.mkForce false;

        systemd.services.navidrome.serviceConfig.BindReadOnlyPaths = [
          "/mnt/wsl/resolv.conf:/mnt/wsl/resolv.conf"
        ];

        wsl = {
          enable = true;
          defaultUser = "myles";
          useWindowsDriver = true;
          startMenuLaunchers = true;
          wslConf = {
            automount.enabled = false;
            interop.appendWindowsPath = true;
            network.generateResolvConf = true;
          };
        };

        nix.settings = {
          max-jobs = 8;
          max-substitution-jobs = 4;
          auto-optimise-store = lib.mkForce false;
          connect-timeout = 30;
          download-attempts = 8;
          http-connections = 10;
          stalled-download-timeout = 180;
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
