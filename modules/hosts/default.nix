{ self, inputs, ... }: {

  flake.nixosModules.base = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.basePackages
      self.nixosModules.chezmoi
    ];

    programs.zsh.enable = true;

    users.users.myles = {
      isNormalUser = true;
      description = "Myles Glanville";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.zsh;
    };

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store   = true;
    };

    nix.gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 30d";
    };

    time.timeZone = "Africa/Johannesburg";
    i18n.defaultLocale = "en_ZA.UTF-8";

    system.stateVersion = "26.05";
  };
}

