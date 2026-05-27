{self, ...}: {
  flake.nixosModules.netbeans = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      netbeans
    ];
  };
}
