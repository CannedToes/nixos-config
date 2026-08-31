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

      # -- wsl --
      inputs.nixos-wsl.nixosModules.default

      # -- host configuration --
      ({
        lib,
        ...
      }: {
        sops.defaultSopsFile = ./secrets.yaml;

        networking.hostName = "wsl";

        networking.dhcpcd.enable = false;
        networking.firewall.trustedInterfaces = ["lo"];
        networking.networkmanager.enable = false;

        networking.nameservers = lib.mkForce [];

        hardware.graphics.enable = lib.mkForce false;

        systemd.network.enable = false;
        systemd.services.systemd-resolved.enable = false;
        systemd.services.systemd-udevd.enable = false;
        systemd.services.systemd-udev-trigger.enable = false;
        services.udev.enable = false;

        wsl = {
          enable = true;
          defaultUser = "myles";
          startMenuLaunchers = false;
          wslConf = {
            network.generateResolvConf = true;
          };
        };
      })
    ];
  };

  perSystem = {...}: {
    packages.wsl = self.nixosConfigurations.wsl.config.system.build.toplevel;
  };
}
