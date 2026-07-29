{...}: {
  flake.nixosModules.theming = {pkgs, ...}: let
    vague-gtk = pkgs.stdenvNoCC.mkDerivation {
      pname = "vague-gtk";
      version = "unstable-2026-04-14";

      src = pkgs.fetchFromGitHub {
        owner = "vague-theme";
        repo = "vague-gtk";
        rev = "bf118ab3e47415e4c558475b241102abd55dad1f";
        hash = "sha256-e76bW8cKjiIwmb6e7/wbXfoB4Fwu8SOs1gLrtzqQRe4=";
      };

      dontBuild = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/share/themes
        cp -r Vague $out/share/themes/Vague
        runHook postInstall
      '';
    };

    monokai-gtk = pkgs.stdenvNoCC.mkDerivation {
      pname = "monokai-gtk";
      version = "unstable-2018-04-03";

      src = pkgs.fetchFromGitHub {
        owner = "mitch-kyle";
        repo = "monokai-gtk";
        rev = "4ab0d6df71601f96365f23c786150a3b5e8a0021";
        hash = "sha256-fJqws14h9WcfqKXA3aIiEGaXSHRQjR4cCil6gfkBums=";
      };

      dontBuild = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/share/themes
        cp -r $src $out/share/themes/monokai
        runHook postInstall
      '';
    };
  in {
    environment = {
      sessionVariables = {
        XCURSOR_SIZE = "24";
        XCURSOR_THEME = "Vanilla-DMZ";
        GTK_THEME = "monokai";
      };

      systemPackages = with pkgs; [
        adwaita-icon-theme
        hicolor-icon-theme
        vanilla-dmz
        vague-gtk
        monokai-gtk
      ];
    };

    gtk.iconCache.enable = true;
  };
}
