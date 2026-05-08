{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.mylesConfig = {
    pkgs,
    lib,
    config,
    ...
  }: {
    imports = [
      inputs.nix-index-database.nixosModules.default
    ];

    sops.secrets."myles/password".neededForUsers = true;

    programs.zsh.enable = true;
    users.users.myles = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."myles/password".path;
      description = "Myles Glanville";
      extraGroups = [
        "networkmanager"
        "wheel"
        "audio"
        "video"
        "media"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFzo2ose4CPJumPhaubPtXZXNkfrXxbObIuI18Vx/Va myles@desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBqTiWPREJZ0wY6wIMW6kbkmK5uqnnG1jl2ga5CHzc9 myles@laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIU1WdfeFe320nwVimkgjb+b7hDS6NL8Tvx8BdwuTYNn myles@wsl"
      ];
      shell = pkgs.zsh;
    };

    users.groups.media = {
      gid = 997;
    };

    environment.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    programs.nix-ld.enable = true;
  };
}
