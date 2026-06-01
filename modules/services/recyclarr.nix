{...}: {
  flake.nixosModules.recyclarr = {...}: {
    services.recyclarr = {
      enable = true;
    };
  };
}
