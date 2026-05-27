{
  self,
  inputs,
  username,
  ...
}: {
  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs username;};

    modules = with self.nixosModules; [
      # -- system --
      locale
      nix
      networking
      sops
      users

      # -- programs --
      emacs
      git
      cli
      neovim

      # -- wsl --
      inputs.nixos-wsl.nixosModules.default

      # -- home-manager --
      {
        home-manager.users.${username} = {
          imports = with self.homeModules; [common];
        };
      }

      # -- host configuration --
      {
        sops.defaultSopsFile = ./secrets.yaml;

        networking.hostName = "wsl";

        wsl = {
          enable = true;
          defaultUser = username;
          useWindowsDriver = true;
          startMenuLaunchers = true;
        };

        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };

        fileSystems."/srv/storage" = {
          device = "D:";
          fsType = "drvfs";
          options = ["uid=1000" "gid=1500" "umask=002" "noatime"];
        };
      }
    ];
  };

  perSystem = {self', ...}: {
    packages.wsl = self.nixosConfigurations.wsl.config.system.build.toplevel;
  };
}
