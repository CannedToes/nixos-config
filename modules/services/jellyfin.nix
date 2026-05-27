{...}: {
  flake.nixosModules.jellyfin = {...}: {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    systemd.services.jellyfin = {
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };

    services.nginx.virtualHosts."jellyfin.myles.onl" = {
      useACMEHost = "myles.onl";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
        extraConfig = "proxy_buffering off;";
      };
    };
  };
}
