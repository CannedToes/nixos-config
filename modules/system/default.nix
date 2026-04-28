{ self, inputs, ... }: {

  flake.nixosModules.system = { lib, pkgs, ... }: {
    imports = [
      self.nixosModules.systemConfiguration
      self.nixosModules.systemPackages
      # self.nixosModules.systemStorage
    ];
  };

}
