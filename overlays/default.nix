{
  inputs,
  self,
  ...
}: {
  flake.overlays.navidrome-plugins = import ./navidrome-plugins.nix {
    inherit inputs;
  };

  flake.overlays.default = self.overlays.navidrome-plugins;

  perSystem = {pkgs, ...}: let
    pkgsWithNavidromePlugins = pkgs.extend self.overlays.navidrome-plugins;
  in {
    packages.audiomuseai =
      pkgsWithNavidromePlugins.navidromePlugins.audiomuseai;
  };
}
