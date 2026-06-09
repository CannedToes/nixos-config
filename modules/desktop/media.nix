{...}: {
  flake.nixosModules.media = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      feishin
      megacmd
      mpv
    ];
  };
}
