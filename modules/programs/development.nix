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
    ];
  };
}
