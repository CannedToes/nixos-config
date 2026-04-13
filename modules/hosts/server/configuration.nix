{ self, inputs, ... }: {

  flake.nixosModules.server = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.base
    ];
  };

}
