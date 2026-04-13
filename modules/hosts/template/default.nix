{ self, inputs, ... }: {

  flake.nixosConfigurations.template = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.template
    ];
  };

}
