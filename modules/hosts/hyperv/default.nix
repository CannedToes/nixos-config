{ self, inputs, ... }: {

  flake.nixosConfigurations.hyperv = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.hyperv
    ];
  };

}
