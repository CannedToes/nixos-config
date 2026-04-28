{ self, inputs, ... }: {

  # these are packages that you want on every host
  flake.nixosModules.systemPackages = { lib, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      age
      curl
      fastfetch
      git
      openssl
      ssh-to-age
      wget
    ];
  };

}
