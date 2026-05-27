{...}: {
  flake.nixosModules.seerr = {...}: {
    services.seerr = {
      enable = true;
      openFirewall = true;
    };

    systemd.services.seerr = {
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };

    services.nginx.virtualHosts."media.myles.onl" = {
      useACMEHost = "myles.onl";
      forceSSL = true;
      locations."/requests" = {
        proxyPass = "http://127.0.0.1:5055";
        proxyWebsockets = true;
      };
    };
  };
}
