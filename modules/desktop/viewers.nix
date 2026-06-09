{...}: {
  flake.nixosModules.viewers = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      imv
      sioyek
      zathura
    ];
  };
}
