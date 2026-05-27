{...}: {
  flake.nixosModules.plex = {...}: {
    services.plex = {
      enable = true;
      openFirewall = true;
    };

    systemd.services.plex = {
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };
  };
}
