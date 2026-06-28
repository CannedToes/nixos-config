{...}: {
  flake.nixosModules.cli = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # system utilities
      busybox
      curl
      dosfstools
      ntfs3g
      p7zip

      # system info & monitoring
      btop
      dust
      fastfetch
      file
      htop
      iotop
      ncdu
      procs

      # navigation
      eza
      zoxide

      # file viewing & search
      bat
      bat-extras.batdiff
      bat-extras.batgrep
      bat-extras.batman
      bat-extras.batwatch
      bat-extras.prettybat
      fd
      fzf
      hexyl
      ripgrep

      # data querying
      choose
      jq
      yq-go

      # output processing
      gron
      jc

      # diffing
      delta

      # terminal
      entr
      pv
      starship
      tealdeer
      tmux

      # network
      bandwhich
			openssl

      # terminal media
      chafa
      viu
    ];
  };
}
