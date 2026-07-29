{...}: {
  flake.nixosModules.dev = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # nix
      alejandra
      nixd

      # build tools
      cmake
      nodejs

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
      gcc
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
      gitFull
      helix
      pandoc

      # secrets
      age
      sops
      ssh-to-age

      # media processing
      ffmpeg
    ];
  };
}
