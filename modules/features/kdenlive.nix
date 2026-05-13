{ ... }: {
  flake.nixosModules.kdenlive = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      (kdePackages.kdenlive.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ makeWrapper ];
        postInstall = (oldAttrs.postInstall or "") + ''
          wrapProgram $out/bin/kdenlive \
            --prefix FREI0R_PATH : ${frei0r}/lib/frei0r-1 \
            --prefix LADSPA_PATH : ${ladspaPlugins}/lib/ladspa \
            --prefix PATH : ${lib.makeBinPath [ mediainfo ffmpeg-full ]}
        '';
      }))
      frei0r
      kdePackages.qtimageformats
      ladspaPlugins
      libva-utils
      mediainfo
      mesa-demos
      vulkan-tools
    ];
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        liberation_ttf
      ];
      fontconfig.localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "fontd.dtd">
        <fontconfig>
          <dir>/mnt/c/Windows/Fonts</dir>
        </fontconfig>
      '';
    };
    environment.sessionVariables = {
      GALLIUM_DRIVER = "d3d12";
      LD_LIBRARY_PATH = "/usr/lib/wsl/lib";
      QT_QPA_PLATFORM = "wayland;xcb";
      XDG_SESSION_TYPE = "wayland";
      NIXOS_OZONE_WL = "1";
    };
  };
}
