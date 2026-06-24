{inputs, ...}: {
  flake.nixosModules.zen = {pkgs, ...}: {
    environment.systemPackages = [
      inputs.zen-browser.packages.${pkgs.system}.default
    ];
  };
}
