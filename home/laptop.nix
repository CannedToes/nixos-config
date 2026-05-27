{inputs, ...}: {
  flake.homeModules.laptop = {pkgs, ...}: {
    imports = [
      inputs.plasma-manager.homeModules.plasma-manager
    ];

    xdg.dataFile."color-schemes/KanagawaLotus.colors".source = ./files/KanagawaLotus.colors;
    xdg.dataFile."konsole/KanagawaLotus.colorscheme".source = ./files/KanagawaLotus.colorscheme;
    xdg.dataFile."konsole/Profile 1.profile".text = ''
      [General]
      Name = Profile 1

      [Appearance]
      ColorScheme = KanagawaLotus
    '';
    xdg.configFile."konsolerc".text = ''
      [General]
      DefaultProfile = Profile 1
    '';

    home.packages = [
      pkgs.kdePackages.krohnkite
    ];

    programs.plasma = {
      enable = true;

      # -- workspace --
      workspace = {
        lookAndFeel = "org.kde.breeze.desktop";
        cursor.theme = "Bibata-Modern-Ice";
        cursor.size = 24;
        wallpaper = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/CannedToes/dotfiles/main/Pictures/wallpapers/kanagawalotus.png";
          hash = "sha256-F1TiQo7w0yYSYW+bJqlbJvREEvvnJmjsYH7jy4352Pg=";
        };
        colorScheme = "KanagawaLotus";
        iconTheme = "Papirus-Light";
      };

      # -- panels --
      panels = [
        {
          location = "top";
          height = 28;
          widgets = [
            {
              applicationTitleBar = {
                behavior.activeTaskSource = "activeTask";
                layout = {
                  elements = ["windowTitle"];
                  horizontalAlignment = "left";
                  showDisabledElements = "deactivated";
                  verticalAlignment = "center";
                };
                overrideForMaximized.enable = false;
                windowTitle = {
                  font = {
                    bold = false;
                    fit = "fixedSize";
                    size = 11;
                  };
                  hideEmptyTitle = true;
                  margins = {
                    bottom = 0;
                    left = 10;
                    right = 5;
                    top = 0;
                  };
                  source = "appName";
                };
              };
            }
            "org.kde.plasma.appmenu"
            "org.kde.plasma.panelspacer"
            {
              systemTray.items = {
                shown = [
                  "org.kde.plasma.battery"
                  "org.kde.plasma.bluetooth"
                  "org.kde.plasma.networkmanagement"
                  "org.kde.plasma.volume"
                ];
                hidden = ["org.kde.plasma.clipboard"];
              };
            }
            {
              digitalClock = {
                calendar.firstDayOfWeek = "sunday";
                time.format = "12h";
              };
            }
          ];
        }

        {
          location = "bottom";
          floating = true;
          alignment = "center";
          lengthMode = "fit";
          hiding = "dodgewindows";
          opacity = "adaptive";
          height = 56;
          widgets = [
            {
              kickoff = {
                icon = "nix-snowflake";
                sortAlphabetically = true;
              };
            }
            {
              iconTasks = {
                launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "applications:org.kde.konsole.desktop"
                  "applications:firefox.desktop"
                ];
              };
            }
            "org.kde.plasma.marginsseparator"
            "org.kde.plasma.trash"
          ];
        }
      ];

      # -- input --
      input = {
        keyboard = {
          repeatDelay = 200;
          repeatRate = 45;
        };
      };

      # -- keyboard shortcuts --
      shortcuts = {
        ksmserver."Lock Session" = ["Screensaver" "Meta+Ctrl+Alt+L"];
        kwin = {
          "Expose" = [];
          "Switch Window Down" = [];
          "Switch Window Left" = [];
          "Switch Window Right" = [];
          "Switch Window Up" = [];

          KrohnkiteFocusNext = "Meta+.";
          KrohnkiteFocusPrev = "Meta+,";
          KrohnkiteFocusDown = "Meta+J";
          KrohnkiteFocusLeft = "Meta+H";
          KrohnkiteFocusRight = "Meta+L";
          KrohnkiteFocusUp = "Meta+K";
          KrohnkiteShiftDown = "Meta+Shift+J";
          KrohnkiteShiftLeft = "Meta+Shift+H";
          KrohnkiteShiftRight = "Meta+Shift+L";
          KrohnkiteShiftUp = "Meta+Shift+K";
          KrohnkiteGrowHeight = "Meta+Ctrl+J";
          KrohnkiteShrinkHeight = "Meta+Ctrl+K";
          KrohnkiteShrinkWidth = "Meta+Ctrl+H";
          KrohnkitegrowWidth = "Meta+Ctrl+L";
          KrohnkiteToggleFloat = "Meta+F";
          KrohnkiteFloatAll = "Meta+Shift+F";
          KrohnkiteNextLayout = "Meta+\\";
          KrohnkitePreviousLayout = "Meta+|";
          KrohnkiteRotate = "Meta+R";
          KrohnkiteRotatePart = "Meta+Shift+R";
          KrohnkiteSetMaster = "Meta+Shift+Return";
          KrohnkiteTileLayout = "Meta+T";
          KrohnkiteMonocleLayout = "Meta+M";
        };
      };

      # -- hotkeys --
      hotkeys.commands."launch-konsole" = {
        name = "Launch Konsole";
        key = "Meta+Enter";
        command = "konsole";
      };

      # -- kwin --
      kwin = {
        edgeBarrier = 0;
        cornerBarrier = false;
        effects.shakeCursor.enable = false;
      };

      configFile."kwinrc" = {
        Tiling.enable = true;
        Tiling.layout = "tile";

        Plugins.krohnkiteEnabled = true;
        Windows = {
          ActiveMouseScreen = false;
          SeparateScreenFocus = true;
        };
        "Script-krohnkite" = {
          screenGapBetween = 6;
          screenGapBottom = 6;
          screenGapLeft = 6;
          screenGapRight = 6;
          screenGapTop = 6;
          screenDefaultLayout = ":tile";
          layoutPerActivity = true;
          layoutPerDesktop = true;
          adjustLayout = true;
          adjustLayoutLive = true;
          floatUtility = true;
          keepTilingOnDrag = true;
          monocleMaximize = true;
          preventProtrusion = true;
          soleWindowNoBorders = false;
          soleWindowNoGaps = true;
          ignoreClass = "krunner,yakuake,spectacle,kded5,xwaylandvideobridge,plasmashell,ksplashqml,org.kde.plasmashell,org.kde.polkit-kde-authentication-agent-1,org.kde.kruler,kruler,kwin_wayland,ksmserver-logout-greeter";
          floatingClass = "";
          floatingTitle = "";
        };
      };

      # -- screen locking --
      kscreenlocker = {
        lockOnResume = true;
        timeout = 10;
      };
    };
  };
}
