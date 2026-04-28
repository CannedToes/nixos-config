{ self, inputs, ... }: {
  flake.nixosModules.wslPackages = { lib, pkgs, ... }: {
    environment.systemPackages = [
      pkgs.wsl-open
    ];
  };
}
