{ self, inputs, ... }: {

  flake.nixosModules.basePackages = { pkgs, lib, ... }: {
    environment.systemPackages = with pkgs; [
      cachix
      curl
      fastfetch
      git
      wget
    ];
  };

}
