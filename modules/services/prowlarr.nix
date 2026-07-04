{...}: {
  flake.nixosModules.prowlarr = {...}: {
    services.prowlarr = {
      enable = true;
      openFirewall = true;
    };
  };
}
