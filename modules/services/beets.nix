{...}: {
  flake.nixosModules.beets = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      beets
      bpm-tools
      chromaprint
      libsndfile
    ];
  };
}
