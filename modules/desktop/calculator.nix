{...}: {
  flake.nixosModules.calculator = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      speedcrunch
    ];
  };
}
