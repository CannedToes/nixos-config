{...}: {
  flake.nixosModules.calculator = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      qalculate-gtk
      speedcrunch
    ];
  };
}
