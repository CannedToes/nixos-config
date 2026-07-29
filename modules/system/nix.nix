{...}: {
  flake.nixosModules.nix = {...}: {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/myles/.config/nixos";
    };

    system.stateVersion = "26.05";
  };
}
