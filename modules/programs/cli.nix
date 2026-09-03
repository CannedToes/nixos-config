{...}: {
  flake.nixosModules.cli = {pkgs, ...}: {
    programs.tmux = {
      enable = true;
    };

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
      tealdeer
      wget
      zoxide
    ];
  };
}
