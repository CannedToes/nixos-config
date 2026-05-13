{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.mylesPackages = {
    pkgs,
    lib,
    config,
    ...
  }: {
    imports = [
      self.nixosModules.fonts
    ];

    users.users.myles.packages = with pkgs; [
      # testing
      helix
      vis

      # neovim
      cargo
      lua-language-server
      luajitPackages.tree-sitter-cli
      neovim
      nil
      rust-analyzer

      # tools
      alejandra
      bat
      chezmoi
      dust
      fd
      ffmpeg
      fzf
      gcc
      jq
      lazygit
      pandoc
      ripgrep
      sops
      tinymist
      tmux
      typst

      # bro why does beets have so many dependencies it doesn't install right
      beets
      bpm-tools
      chromaprint
      libsndfile
    ];
  };
}
