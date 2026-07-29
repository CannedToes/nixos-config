{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchzip,
  bun,
  makeWrapper,
}: let
  bunBaseline = bun.overrideAttrs (old: {
    src = fetchzip {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v1.3.13/bun-linux-x64-baseline.zip";
      hash = "sha256-39w4IMLFa7xLRBlMBBDASU1BhnjzR3jyswEYFysfBXo=";
    };
  });

  src = fetchFromGitHub {
    owner = "degoog-org";
    repo = "degoog";
    rev = "0.23.0";
    hash = "sha256-+ReSP9pMgt92E9Li9G36eQYoLuwd94ZZ9c4j/3eb068=";
  };

  bunDeps = stdenvNoCC.mkDerivation {
    pname = "degoog-bun-deps";
    version = "0.23.0";
    inherit src;

    nativeBuildInputs = [bunBaseline];

    buildPhase = ''
      export HOME="$TMPDIR"
      bun install --frozen-lockfile
    '';

    installPhase = ''
      mkdir -p "$out"
      cp -r node_modules "$out/"
    '';

    dontFixup = true;

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-C61dko2C8XyuzNESGMSbCqeMNgKEwK2+/KadPlaZabg=";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "degoog";
    version = "0.23.0";
    inherit src;

    nativeBuildInputs = [bunBaseline makeWrapper];

    preConfigure = ''
      cp -r "${bunDeps}/node_modules" node_modules
      chmod -R +w node_modules
    '';

    configurePhase = ''
      runHook preConfigure
      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild
      bun run build.ts
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/degoog" "$out/bin"
      cp -r src package.json bun.lock node_modules "$out/share/degoog/"
      rm -rf "$out/share/degoog/node_modules/.cache"
      makeWrapper ${bunBaseline}/bin/bun "$out/bin/degoog" \
        --add-flags "run $out/share/degoog/src/server/index.ts" \
        --chdir "$out/share/degoog"
      runHook postInstall
    '';

    meta = {
      description = "Self-hosted search engine aggregator with plugin support";
      homepage = "https://github.com/degoog-org/degoog";
      license = lib.licenses.agpl3Only;
      platforms = lib.platforms.linux;
      mainProgram = "degoog";
    };
  }
