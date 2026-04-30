{ self, inputs, ... }: {
  flake.nixosModules.wslServices = { pkgs, lib, config, ... }: {
    imports = [
      # media server
      self.nixosModules.navidrome
    ];
  };
}
