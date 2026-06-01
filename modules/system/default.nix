{...}: {
  flake.nixosModules.system = {...}: {
    imports = [
      ./locale.nix
      ./nix.nix
      ./networking.nix
      ./sops.nix
      ./users.nix
    ];
  };
}
