{...}: {
  flake.nixosModules.recyclarr = {...}: {
    services.recyclarr = {
      enable = true;
      configuration = {};
    };

    systemd.services.recyclarr = {
      wantedBy = ["multi-user.target"];
    };
  };
}
