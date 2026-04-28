{ self, inputs, ... }: {

  flake.nixosModules.myles = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.mylesConfig
      self.nixosModules.mylesPackages
      # self.nixosModules.mylesChezmoi
    ];
  };

}
