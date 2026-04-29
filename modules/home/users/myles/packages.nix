{ self, inputs, ... }: {

  flake.nixosModules.mylesPackages = { pkgs, ... }: {
    imports = [
      self.nixosModules.fonts
    ];

    users.users.myles.packages = with pkgs; [
      alejandra
      bat
      cargo
      chezmoi
      dust
      fd
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
    ];
  };

}
