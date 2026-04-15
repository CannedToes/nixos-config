{ self, inputs, ... }: {

  flake.nixosModules.basePackages = { pkgs, lib, ... }: {
    environment.systemPackages = with pkgs; [
    ];
  };

}
