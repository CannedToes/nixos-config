{...}: {
  flake.nixosModules.prowlarr = {...}: {
    services.prowlarr = {
      enable = true;
      openFirewall = true;
    };

    systemd.services.prowlarr = {
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };
  };
}
