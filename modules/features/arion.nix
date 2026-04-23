{ self, inputs, ... }: {

  flake.nixosModules.arion = { config, pkgs, lib, ... }:
    let
      cfg = config.modules.arion;
    in {
      options.modules.arion = {
        user = lib.mkOption {
          type = lib.types.str;
          default = "myles";
          description = "The user to add to the relevant groups to use podman";
        };
      };

      imports = [
        inputs.arion.nixosModules.arion
      ];

      config = {
        environment.systemPackages = [
          pkgs.arion
          pkgs.docker-client
        ];

        virtualisation.containers.enable = true;
        virtualisation.docker.enable = false;
        virtualisation.podman.enable = true;
        virtualisation.podman.dockerSocket.enable = true;
        virtualisation.podman.dockerCompat = true;
        virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

        virtualisation.arion.backend = "podman-socket";

        users.users.${cfg.user}.extraGroups = [ "podman" "docker" ];
      };
    };
}
