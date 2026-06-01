{inputs}: final: prev: {
  buildNavidromePlugin =
    final.callPackage "${inputs.nixpkgs}/pkgs/by-name/na/navidrome/plugins/build-plugin.nix" {};

  navidromePlugins =
    prev.navidromePlugins
    // {
      audiomuseai =
        final.callPackage ../pkgs/by-name/na/navidrome/plugins/audiomuseai/package.nix {};
    };
}
