{ self, inputs, ... }: {
  flake.nixosModules.fonts = { pkgs, ... }: {
    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.noto
      nerd-fonts.liberation
      nerd-fonts.hack
      nerd-fonts.sauce-code-pro
      nerd-fonts.commit-mono
      nerd-fonts.space-mono
      nerd-fonts.jetbrains-mono
    ];
  };
}
