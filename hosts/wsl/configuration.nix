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
      ({lib, ...}: {
        sops.defaultSopsFile = ./secrets.yaml;

        networking.hostName = "wsl";

        networking.dhcpcd.enable = false;
        networking.firewall.trustedInterfaces = ["lo"];
        networking.networkmanager.enable = false;

        networking.nameservers = lib.mkForce [];

        hardware.graphics.enable = lib.mkForce false;

        wsl = {
          enable = true;
          defaultUser = "myles";
          startMenuLaunchers = false;
          interop.includePath = false;
          wslConf = {
            automount.enabled = false;
            interop.appendWindowsPath = false;
          };
        };
      })
    ];
  };

}
