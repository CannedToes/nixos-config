{ self, inputs, ... }: {

  flake.nixosModules.mylesPackages = { pkgs, lib, ... }: {
    users.users.myles.packages = with pkgs; [
      luajitPackages.tree-sitter-cli
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
