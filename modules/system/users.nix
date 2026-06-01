{
  username,
  inputs,
  ...
}: {
  flake.nixosModules.users = {
    pkgs,
    config,
    lib,
    ...
  }: {
    imports = [
      inputs.home-manager.nixosModules.default
    ];

    users.groups.media.gid = 1500;

    users.users.${username} = {
      isNormalUser = true;
      initialPassword = "changeme";
      description = "Myles Glanville";
      extraGroups = ["networkmanager" "wheel" "audio" "video" "media" "dialout"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBqTiWPREJZ0wY6wIMW6kbkmK5uqnnG1jl2ga5CHzc9 myles@laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIU1WdfeFe320nwVimkgjb+b7hDS6NL8Tvx8BdwuTYNn myles@wsl"
      ];
      shell = pkgs.zsh;
    };

    programs.zsh.enable = true;

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";
      overwriteBackup = true;
      extraSpecialArgs = {inherit inputs username;};
    };

    environment.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
