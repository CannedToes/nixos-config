{...}: {
  flake.nixosModules.dev = {pkgs, ...}: {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
    };

    environment.systemPackages = with pkgs; [
      # nix
      nixd

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
      clang-tools
      gcc

      # lua
      lua-language-server
      stylua

      # typst
      tinymist
      typst
      typstyle

      # general
      helix
      devenv
    ];
  };
}
