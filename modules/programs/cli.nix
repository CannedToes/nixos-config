{...}: {
  flake.nixosModules.cli = {pkgs, ...}: {
    programs = {
      tmux.enable = true;
      bat.enable = true;
      zoxide.enable = true;
      less.enable = true;
    };

    environment = {
      systemPackages = with pkgs; [
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
      ];

      sessionVariables = {
        PAGER = "less";
        LESS = "-R -i -S";
      };
    };
  };
}
