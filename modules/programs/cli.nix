{...}: {
  flake.nixosModules.cli = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      bat
      btop
      curl
      delta
      fastfetch
      fd
      fzf
      jq
      ncdu
      ripgrep
      starship
      tealdeer
      tmux
      zoxide
    ];
  };
}
