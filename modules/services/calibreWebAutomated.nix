{...}: {
  flake.nixosModules.calibreWebAutomated = {...}: {
    virtualisation.oci-containers.backend = "podman";

    virtualisation.oci-containers.containers.calibre-web-automated = {
      image = "docker.io/crocodilestick/calibre-web-automated:latest";
      autoStart = true;

      environment = {
        PUID = "1001";
        PGID = "1001";
        TZ = "Africa/Johannesburg";
        NETWORK_SHARE_MODE = "true";
      };

      volumes = [
        "/var/lib/calibre-web-automated/config:/config"
        "/srv/storage/downloads/ingest:/cwa-book-ingest"
        "/srv/storage/media/books:/calibre-library"
      ];

      ports = ["127.0.0.1:8083:8083"];
    };

    services.nginx.virtualHosts."calibre.myles.onl" = {
      useACMEHost = "myles.onl";
      forceSSL = true;
      extraConfig = ''
        proxy_buffering off;
        client_max_body_size 0;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:8083";
        proxyWebsockets = true;
      };
    };
  };
}
