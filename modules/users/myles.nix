{ self, inputs, ... }: {

  flake.nixosModules.myles = { pkgs, lib, ... }: {
    imports = [
      inputs.nix-index-database.nixosModules.default
      self.nixosModules.mylesPackages
      self.nixosModules.chezmoi
    ];

    users.users.myles = {
      isNormalUser = true;
      description = "Myles Glanville";
      extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
      shell = pkgs.zsh;
    };

    environment.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      MANPAGER = "nvim +Man!";
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration  = true;
    };

    programs.nix-ld.enable = true;
  };

}
