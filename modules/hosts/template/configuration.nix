{ self, inputs, ... }: {

  flake.nixosModules.template = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.base
    ];
  };

}
