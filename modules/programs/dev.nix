{...}: {
  flake.nixosModules.dev = {pkgs, ...}: {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
    };

    environment.systemPackages = with pkgs; [
      helix
      nixd
      tinymist
      typst
      typstyle

      # cargo
      # rust-analyzer
      # rustfmt

      # basedpyright
      # isort
      # python3
      # ruff
    ];
  };
}
