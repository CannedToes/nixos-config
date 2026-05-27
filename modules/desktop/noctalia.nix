{inputs, ...}: {
  flake.nixosModules.noctalia = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
