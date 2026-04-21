{ self, inputs, ... }: {

  flake.nixosModules.mylesPackages = { pkgs, ... }: {
    imports = [
      self.nixosModules.fonts
    ];

    users.users.myles.packages = with pkgs; [
      luajitPackages.tree-sitter-cli
      gcc
      cargo
      neovim
      ripgrep
      fzf
      fd
      bat
      gh
    ];
  };

}
