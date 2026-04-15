{ self, inputs, ... }: {

  flake.nixosModules.myles = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.mylesPackages
    ];

    users.users.myles = {
      isNormalUser = true;
      description = "Myles Glanville";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.zsh;
    };
  };

}
