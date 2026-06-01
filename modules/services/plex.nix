{...}: {
  flake.nixosModules.plex = {...}: {
    services.plex = {
      enable = true;
      openFirewall = true;
    };
  };
}
