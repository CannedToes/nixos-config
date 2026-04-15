{ self, inputs, ... }: {

  flake.nixosModules.hyperv = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.base
    ];
  };

}
