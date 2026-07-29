{...}: {
  flake.nixosModules.fonts = {pkgs, ...}: {
    fonts.packages = with pkgs; [
      liberation_ttf
      nerd-fonts.commit-mono
      nerd-fonts.symbols-only
      noto-fonts-color-emoji
    ];
  };
}
