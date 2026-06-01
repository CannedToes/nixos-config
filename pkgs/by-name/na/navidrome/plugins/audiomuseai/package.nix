{
  lib,
  fetchFromGitHub,
  buildNavidromePlugin,
}:
buildNavidromePlugin rec {
  pname = "audiomuse-ai-nv-plugin";
  version = "8";

  src = fetchFromGitHub {
    owner = "NeptuneHub";
    repo = "audiomuse-ai-nv-plugin";
    rev = "v${version}";
    hash = "sha256-WyobjyadD9IcY6mFYhCmuQgLbnoHpDoiLfINNfKmQM8=";
  };

  vendorHash = "sha256-mXes+doBSa5kcfHp1cuzTz30wnyyPN7NLC0iOSL8FDo=";

  meta = {
    description = "Uses AudioMuse-AI to better recommend sonically similar and relevant music/artists through Navidrome";
    homepage = "https://github.com/NeptuneHub/AudioMuse-AI-NV-plugin";
    license = lib.licenses.agpl3Only;
    sourceProvenance = with lib.sourceTypes; [fromSource];
  };
}
