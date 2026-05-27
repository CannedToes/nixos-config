{...}: {
  flake.nixosModules.nix = {lib, ...}: {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      download-buffer-size = 524288000;
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSl9SZiZBKUDjj8Tk4UMqfY7S5sJqvP9MZ9F9YdM="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = lib.mkDefault "--delete-older-than 7d";
    };

    system.stateVersion = "26.05";
  };
}
