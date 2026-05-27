{
  self,
  inputs,
  username,
  ...
}: {
  flake.nixosConfigurations.server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs username;};

    modules = with self.nixosModules; [
      # -- disko disk --
      inputs.disko.nixosModules.default
      ./disko.nix

      # -- system --
      locale
      nix
      networking
      sops
      users

      # -- programs --
      cli
      git
      neovim

      # -- services --
      avahi
      ddclient
      homeAssistant
      nginx
      ntfy
      podman
      vaultwarden

      # -- home-manager --
      {
        home-manager.users.${username} = {
          imports = with self.homeModules; [common];
        };
      }

      # -- host config --
      ({lib, ...}: {
        hardware.facter.reportPath = ./facter.json;
        sops.defaultSopsFile = ./secrets.yaml;

        networking.hostName = "server";

        boot = {
          loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          };
          kernelParams = ["quiet"];
        };

        services.xserver.enable = false;

        # -- networking --
        networking.useDHCP = true;

        nix.settings.max-jobs = 4;
        nix.gc.options = lib.mkForce "--delete-older-than 3d";
      })
    ];
  };

  perSystem = {self', ...}: {
    packages.server = self.nixosConfigurations.server.config.system.build.toplevel;
    packages.server-vm = self.nixosConfigurations.server.config.system.build.vm;
  };
}
