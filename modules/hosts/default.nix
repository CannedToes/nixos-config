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

      extra-substituters = [
        "http://mylesdesktop:5000"
      ];

      extra-trusted-public-keys = [
        "cache.wsl.local:EGWy7o70ndO2jBDFnfhLU+nJlAqleqs7rP3HFEzim/k="
      ];

    };

    nix.gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 7d";
    };

    services.openssh.enable = true;

    time.timeZone = "Africa/Johannesburg";
    i18n.defaultLocale = "en_ZA.UTF-8";

    system.stateVersion = "26.05";
  };
}

