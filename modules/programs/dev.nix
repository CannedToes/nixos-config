{...}: {
  flake.nixosModules.dev = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # nix
      nixd

      # build tools
      cmake
      nodejs

      # rust
      cargo
      rust-analyzer
      rustfmt

      # python
      basedpyright
      isort
      python3
      ruff

      # c/c++
      gcc
      clang-tools

      # lua
      lua-language-server
      stylua

      # typst
      tinymist
      typst
      typstyle

      # general dev
      git
      pandoc

      # secrets
      age
      sops
      ssh-to-age
    ];
  };
}
