{...}: {
  flake.nixosModules.fonts = {pkgs, ...}: {
    fonts.packages = with pkgs; [
      atkinson-hyperlegible
      geist-font
      ibm-plex
      liberation_ttf
      maple-mono.NF
      monaspace
      nerd-fonts.commit-mono
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      nerd-fonts.liberation
      nerd-fonts.noto
      nerd-fonts.sauce-code-pro
      nerd-fonts.space-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      recursive
    ];
  };
}
