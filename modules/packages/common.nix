{ self, inputs, ... }: {

  flake.nixosModules.basePackages = { pkgs, lib, ... }: {
    environment.systemPackages = with pkgs; [
      tmux
      rippkgs
      chezmoi
      fastfetch
      wget
      curl
      dust
      git
    ];
  };

}
