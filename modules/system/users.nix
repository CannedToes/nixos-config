{...}: {
  flake.nixosModules.users = {pkgs, ...}: {
    users.groups.media.gid = 1500;

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
        # -- shell --
        bat
        bat-extras.batdiff
        bat-extras.batgrep
        bat-extras.batman
        bat-extras.batwatch
        bat-extras.prettybat
        btop
        delta
        fzf
        starship
        tmux
        zoxide

        # -- cli tools --
        dust
        fastfetch
        fd
        hexyl
        jq
        kakoune
        lazygit
        ripgrep
        tokei
        yq-go

        # -- media and documents --
        ffmpeg
        pandoc
        typst

        # -- encryption --
        age
        sops
        ssh-to-age

        # -- language stuff --
        alejandra
        basedpyright
        cargo
        chafa
        clang-tools
        glsl_analyzer
        isort
        lua-language-server
        nixd
        ruff
        rust-analyzer
        rustfmt
        stylua
        tinymist
        typstyle
        ueberzugpp
        viu
        zig
        zls

        # -- misc --
        chezmoi
        file
        tree
        which
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
