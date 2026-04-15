{ self, inputs, ... }: {

  flake.nixosModules.base = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.basePackages
    ];

    programs.zsh.enable = true;

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store   = true;
      download-buffer-size = 524288000; # 500 MiB
    };

    nix.gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 30d";
    };

    nix.optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    time.timeZone = "Africa/Johannesburg";
    i18n.defaultLocale = "en_ZA.UTF-8";

    system.stateVersion = "26.05";
  };
}

