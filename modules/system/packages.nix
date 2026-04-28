{ self, inputs, ... }: {

  # these are packages that you want on every host
  flake.nixosModules.systemPackages = { lib, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      curl
      fastfetch
      git
      wget
    ];
  };

}
