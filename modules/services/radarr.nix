{...}: {
  flake.nixosModules.radarr = {...}: {
    services.radarr = {
      enable = true;
      openFirewall = true;
    };

    users.users.radarr.extraGroups = ["media"];

    systemd.services.radarr = {
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };
  };
}
