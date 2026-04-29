{ self, inputs, ... }: {

  flake.nixosModules.mylesConfig = { pkgs, lib, config, ... }: {
    imports = [
      inputs.nix-index-database.nixosModules.default
    ];

    sops.secrets."myles/password".neededForUsers = true;

    programs.zsh.enable = true;
    users.users.myles = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."myles/password".path;
      description = "Myles Glanville";
      extraGroups = [ "networkmanager" "wheel" "audio" "video" "media" ];
      openssh.authorizedKeys.keys = [
      	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPi8iWjLYelkdtAxwtkyitDtnrZNGM6qxa68aN7svZBk myles@wsl"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFzo2ose4CPJumPhaubPtXZXNkfrXxbObIuI18Vx/Va myles@desktop"
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
