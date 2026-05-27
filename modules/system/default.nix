{
<<<<<<< HEAD
  self,
  inputs,
  ...
}: {
  flake.nixosModules.system = {
    lib,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.systemConfiguration
      self.nixosModules.systemPackages
      self.nixosModules.systemSops
    ];
  };
||||||| (empty tree)
=======
  imports = [
    ./locale.nix
    ./nix.nix
    ./networking.nix
    ./sops.nix
    ./users.nix
  ];
>>>>>>> 8a283fc (GINEMINANORMOUS REFACTOR)
}
