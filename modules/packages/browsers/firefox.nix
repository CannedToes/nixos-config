{ self, inputs, ... }: {

  flake.nixosModules.firefox = { pkgs, lib, ... }: {
    programs.firefox.enable = true;
  };

}
