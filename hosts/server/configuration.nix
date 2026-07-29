{
  self,
  inputs,
  ...
}: let
  subdomains = import ../../modules/_subdomains.nix;
in {
  flake.nixosConfigurations.server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = with self.nixosModules; [
      # -- disko disk --
      inputs.disko.nixosModules.default
      ./_disko.nix

      # -- system --
      locale
      nix
      networking
      sops

      # -- services --
      avahi
      copyparty
      ddclient
      degoog
      homeAssistant
      omnisearch
      mealie
      nginx
      ntfy
      vaultwarden

      # -- host config --
      ({...}: {
        hardware.facter.reportPath = ./facter.json;
        sops.defaultSopsFile = ./secrets.yaml;

        services.degoog = {
          enable = true;
          domain = "degoog.myles.onl";
          distrustProxy = false;
          nginx.useACMEHost = "myles.onl";

          defaultEngines = {
            duckduckgo = true;
            brave = true;
            # google = false;  # requires official-extensions engine
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
            google = {
              enable = true;
              src = inputs.official-extensions;
              subpath = "engines/google";
            };
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
          };
        };

        networking = {
          hostName = "server";
          useDHCP = false;

          bridges.br0.interfaces = ["eth0"];
          interfaces = {
            br0 = {
              useDHCP = true;
              macAddress = "1c:69:7a:d9:e0:75";
            };
            eth0.useDHCP = false;
          };

          hosts."127.0.0.1" = subdomains;
        };

        boot = {
          loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          };
          kernelParams = ["quiet"];
        };

        programs.git.enable = true;

        services.xserver.enable = false;

        nix.settings.max-jobs = 4;
      })
    ];
  };

  perSystem = {...}: {
    packages.server = self.nixosConfigurations.server.config.system.build.toplevel;
    packages.server-vm = self.nixosConfigurations.server.config.system.build.vm;
  };
}
