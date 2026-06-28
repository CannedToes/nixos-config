{...}: {
  flake.nixosModules.development = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # nix
      alejandra
      nixd

      # rust
      cargo
      rust-analyzer
      rustfmt

      # zig
      zig
      zls

      # python
      basedpyright
      isort
      python3
      ruff

      # c/c++
      clang-tools
      glsl_analyzer

      # lua
      lua-language-server
      stylua

      # typst
      tinymist
      typst
      typstyle

      # general dev
      chezmoi
      helix
      lazygit
      pandoc
      tokei
      ueberzugpp

      # secrets
      age
      sops
      ssh-to-age

      # media processing
      ffmpeg

      # text processing
      grex
      sd

      # dev utilities
      difftastic
      just
      hyperfine
      watchexec

      # nix diagnostics
      nix-output-monitor
      nix-du
      nvd
    ];
  };
}
