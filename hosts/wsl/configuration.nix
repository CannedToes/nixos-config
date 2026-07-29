{
  self,
  inputs,
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
      cli
      dev
      neovim
      emacs

      # -- wslg --
      fonts

      # -- services --
      navidrome
      jellyfin

      # -- wsl --
      inputs.nixos-wsl.nixosModules.default

      # -- host configuration --
      ({
        config,
        pkgs,
        lib,
        ...
      }: {
        hardware.graphics.enable = true;
        services.pulseaudio.enable = true;

        sops.defaultSopsFile = ./secrets.yaml;

        networking.hostName = "wsl";

        networking.dhcpcd.enable = false;
        networking.firewall.trustedInterfaces = ["lo"];
        networking.networkmanager.enable = false;

        systemd.network.enable = false;
        systemd.services.systemd-resolved.enable = false;
        systemd.services.systemd-udevd.enable = false;

        nixpkgs.overlays = [inputs.emacs-overlay.overlays.default];

        wsl = {
          enable = true;
          defaultUser = "myles";
          startMenuLaunchers = true;
          wslConf = {
            automount.enabled = false;
            interop.appendWindowsPath = false;
            network.generateResolvConf = false;
          };
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
      })
    ];
  };

  perSystem = {...}: {
    packages.wsl = self.nixosConfigurations.wsl.config.system.build.toplevel;
  };
}
