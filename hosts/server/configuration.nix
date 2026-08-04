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
      flaresolverr
      homeAssistant
      mealie
      nginx
      ntfy
      suwayomi
      vaultwarden

      # -- host config --
      ({pkgs, ...}: {
        hardware.facter.reportPath = ./facter.json;
        sops.defaultSopsFile = ./secrets.yaml;

        networking = {
          hostName = "server";
          interfaces.eth0.macAddress = "1c:69:7a:d9:e0:75";
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

        environment.systemPackages = with pkgs; [gitFull];

        nix.settings.max-jobs = 4;
      })
    ];
  };

  perSystem = {...}: {
    packages.server = self.nixosConfigurations.server.config.system.build.toplevel;
  };
}
