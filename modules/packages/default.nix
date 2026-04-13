{ self, inputs, ... }: {

  flake.nixosModules.basePackages = { pkgs, lib, ... }: {
    environment.systemPackages = with pkgs; [
      fastfetch
      gcc
      chezmoi
      git
      wget
      curl
      vim
      dust
    ];

    users.users.myles.packages = with pkgs; [
      neovim
      ripgrep
      fzf
      fd
      bat
      gh
    ];
  };

}
