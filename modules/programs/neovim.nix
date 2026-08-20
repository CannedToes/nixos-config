{...}: {
  flake.nixosModules.neovim = {pkgs, ...}: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    environment.systemPackages = with pkgs; [
      clang-tools
      gcc
      lua-language-server
      luajitPackages.tree-sitter-cli
      stylua
    ];
  };
}
