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
      ./_disko.nix

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
      kavita
      movim
      nginx
      ntfy
      podman
      prosody
      radicale
      vaultwarden

      # -- host config --
      ({...}: {
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
      })
    ];
  };

  perSystem = {...}: {
    packages.server = self.nixosConfigurations.server.config.system.build.toplevel;
    packages.server-vm = self.nixosConfigurations.server.config.system.build.vm;
  };
}
