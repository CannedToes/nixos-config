{ self, inputs, ... }: {

  flake.nixosModules.myles = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.mylesPackages
      self.nixosModules.chezmoi
    ];

    users.users.myles = {
      isNormalUser = true;
      description = "Myles Glanville";
      extraGroups = [ "networkmanager" "wheel" "audio" "docker" ];
      shell = pkgs.zsh;
    };
  };

}
