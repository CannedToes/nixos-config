{ self, inputs, ... }: {

  flake.nixosModules.wsl = { pkgs, lib, ... }: {
    imports = [
      inputs.nixos-wsl.nixosModules.default
      self.nixosModules.base
    ];

    networking.hostName = "wsl";

    wsl = {
      enable = true;
      defaultUser = "myles";
    };

  };
}
