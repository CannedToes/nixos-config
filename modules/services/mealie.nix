{...}: {
  flake.nixosModules.mealie = {...}: {
    networking.firewall.allowedTCPPorts = [9000];
    services.mealie = {
      enable = true;
      database.createLocally = true;
    };
    services.nginx.virtualHosts."mealie.myles.onl" = {
      useACMEHost = "myles.onl";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9000";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_redirect off;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };
}
