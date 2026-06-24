{...}: {
  flake.nixosModules.users = {pkgs, ...}: {
    users.users.myles = {
      isNormalUser = true;
      initialPassword = "changeme";
      description = "Myles Glanville";
      extraGroups = ["networkmanager" "wheel" "audio" "video" "media" "dialout"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBqTiWPREJZ0wY6wIMW6kbkmK5uqnnG1jl2ga5CHzc9 myles@laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIU1WdfeFe320nwVimkgjb+b7hDS6NL8Tvx8BdwuTYNn myles@wsl"
      ];
      packages = with pkgs; [
        bat
        bat-extras.batdiff
        bat-extras.batgrep
        bat-extras.batman
        bat-extras.batwatch
        bat-extras.prettybat
        btop
        chafa
        delta
        dust
        fastfetch
        fd
        ffmpeg
        file
        fzf
        hexyl
        jq
        ripgrep
        starship
        tmux
        tree
        viu
        which
        yq-go
        age
        sops
        ssh-to-age
        zoxide
      ];
      shell = pkgs.zsh;
    };

    programs.zsh.enable = true;

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    environment.sessionVariables = {
      EDITOR = "nvim";
      PAGER = "delta";
      VISUAL = "nvim";
    };
  };
}
