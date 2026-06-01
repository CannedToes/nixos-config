{username, ...}: {
  flake.homeModules.common = {pkgs, ...}: {
    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "26.05";

    # -- shell --
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = ["--cmd cd"];
    };

    programs.starship = {
      enable = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batgrep
        batman
        batwatch
        prettybat
      ];
    };

    programs.git = {
      enable = true;
      settings = {
        core.autocrlf = "input";
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        user.email = "mylesglanville@gmail.com";
        user.name = "Myles Glanville";
      };
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };

    programs.tmux = {
      enable = true;
      keyMode = "vi";
      mouse = true;
      shortcut = "a";
    };

    programs.btop = {
      enable = true;
      settings = {
        color_theme = "kanagawa-lotus";
        theme_background = true;
      };
    };

    xdg.enable = true;

    home.packages = with pkgs; [
      # -- cli tools --
      dust
      fastfetch # "tools"
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
  };
}
