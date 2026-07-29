{...}: {
  flake.nixosModules.lidarr = {...}: {
    services.lidarr = {
      enable = true;
      openFirewall = true;
    };
  };
}
