{inputs, ...}: {
  flake.nixosModules.degoog = {config, ...}: {
    imports = [
      ../../pkgs/degoog/_module.nix
    ];

    sops.secrets.degoog-passwords = {};

    services.degoog = {
      enable = true;
      domain = "degoog.myles.onl";
      nginx.useACMEHost = "myles.onl";

      settings = {
        settingsPasswordFile = config.sops.secrets.degoog-passwords.path;
        distrustProxy = false;
      };

      defaultEngines = {
        duckduckgo = true;
        brave = true;
        startpage = true;
        google = false;
      };

      plugins = {
        weather = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "plugins/weather";
        };
        define = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "plugins/define";
        };
        qr = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "plugins/qr";
        };
        time = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "plugins/time";
        };
        password = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "plugins/password";
        };
        math-slot = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "plugins/math-slot";
        };
        tmdb-slot = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "plugins/tmdb-slot";
        };
      };

      engines = {
        # Web
        brave = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/brave";
        };
        duckduckgo = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/duckduckgo";
        };
        startpage = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/startpage";
        };
        google = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/google";
        };
        ecosia = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/ecosia";
        };
        bing = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/bing";
        };

        # Images
        brave-images = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/brave-images";
        };
        duckduckgo-images = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/duckduckgo-images";
        };
        google-images = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/google-images";
        };
        openverse = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/openverse";
        };

        # Videos
        bing-videos = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/bing-videos";
        };
        google-videos = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/google-videos";
        };

        # News
        brave-news = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/brave-news";
        };
        duckduckgo-news = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/duckduckgo-news";
        };
        bing-news = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/bing-news";
        };

        # Communities
        reddit = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/reddit";
        };
        hacker-news = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/hacker-news";
        };
        lemmy = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/lemmy";
        };

        # Reference
        wikipedia = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/wikipedia";
        };
        internet-archive = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/internet-archive";
        };
        the-guardian = {
          enable = true;
          src = inputs.official-extensions;
          subpath = "engines/the-guardian";
        };
      };
    };
  };
}
