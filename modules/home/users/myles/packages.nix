{ self, inputs, ... }: {

  flake.nixosModules.mylesPackages = { pkgs, lib, config, ... }: {
    imports = [
      self.nixosModules.fonts
    ];

    nixpkgs.overlays = [ self.overlays.default ];

    users.users.myles.packages = with pkgs; [
      alejandra
      bat
      cargo
      chezmoi
      dust
      fd
      ffmpeg
      fzf
      gcc
      helix
      jq
      kakoune
      luajitPackages.tree-sitter-cli
      neovim
      ripgrep
      sops
      tmux
      vis

      # bro why does beets have so many dependencies it doesn't install
      beets
      bpm-tools
      chromaprint
      libsndfile
    ];
  };

}
