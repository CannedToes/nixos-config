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
      persistence
      sops

      # -- services --
      avahi
      ddclient
      homeAssistant
      kavita
      matrix
      movim
      nginx
      ntfy
      prosody
      radicale
      searx
      vaultwarden

      # -- host config --
      ({...}: {
        hardware.facter.reportPath = ./facter.json;
        sops.defaultSopsFile = ./secrets.yaml;

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

          hosts = {
            "127.0.0.1" = [
              "myles.onl"
              "chat.myles.onl"
              "home.myles.onl"
              "kavita.myles.onl"
              "matrix.myles.onl"
              "element.myles.onl"
              "ntfy.myles.onl"
              "radicale.myles.onl"
              "search.myles.onl"
              "upload.myles.onl"
              "vault.myles.onl"
              "xmpp.myles.onl"
              "conference.myles.onl"
              "jellyfin.myles.onl"
              "navidrome.myles.onl"
              "turn.myles.onl"
            ];
          };

        };

        boot = {
          loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          };
          kernelParams = ["quiet"];
        };

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
