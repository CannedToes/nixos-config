{...}: {
  flake.nixosModules.sonarr = {config, ...}: {
    sops.secrets.sonarr = {};

    services.sonarr = {
      enable = true;
      openFirewall = true;
      environmentFiles = [config.sops.secrets.sonarr.path];
    };

    users.users.sonarr.extraGroups = ["media"];
  };
}
