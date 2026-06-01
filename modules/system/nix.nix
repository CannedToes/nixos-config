{...}: {
  flake.nixosModules.nix = {...}: {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      download-buffer-size = 524288000;
    };

    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };

    system.stateVersion = "26.05";
  };
}
