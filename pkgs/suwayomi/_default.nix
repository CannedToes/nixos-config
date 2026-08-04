{
  pkgs,
  lib,
}: let
  version = "2.3.2243";
in
  pkgs.suwayomi-server.overrideAttrs (old: {
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/Suwayomi/Suwayomi-Server/releases/download/v${version}/Suwayomi-Server-v${version}.jar";
      hash = "sha256-ghFBsy4XDUoC08vf7Vd+2PB70iOD/19BMuu1rkDpjdU=";
    };

    meta =
      old.meta
      // {
        changelog = "https://github.com/Suwayomi/Suwayomi-Server/releases/tag/v${version}";
      };
  })
