{...}: {
  flake.nixosModules.beets = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      beets
      ffmpeg
      chromaprint
    ];
  };
}
