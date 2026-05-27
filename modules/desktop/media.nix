# -- Media players and cloud sync --
{...}: {
  flake.nixosModules.media = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      feishin
      megacmd
      megasync
      mpv
    ];
  };
}
