{ self, inputs, ... }: {

  flake.nixosModules.mylesConfig = { pkgs, lib, ... }: {
    imports = [
      inputs.nix-index-database.nixosModules.default
    ];

    programs.zsh.enable = true;
    users.users.myles = {
      isNormalUser = true;
      description = "Myles Glanville";
      extraGroups = [ "networkmanager" "wheel" "audio" "video" "media" ];
      openssh.authorizedKeys.keys = [
      	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPi8iWjLYelkdtAxwtkyitDtnrZNGM6qxa68aN7svZBk myles@wsl"
      ];
      shell = pkgs.zsh;
    };
    users.groups.media = { };

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
