{...}: {
  flake.nixosModules.neovim = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      luajitPackages.tree-sitter-cli
      neovim
    ];
  };
}
