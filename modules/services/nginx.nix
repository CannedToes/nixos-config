{...}: {
  flake.nixosModules.nginx = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets.acme = {};

    networking.firewall.allowedTCPPorts = [80 443];
    networking.firewall.allowedUDPPorts = [443];

    services.nginx = {
      enable = true;
      serverTokens = false;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      additionalModules = [pkgs.nginxModules.moreheaders];

      commonHttpConfig = ''
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
        proxy_headers_hash_max_size 1024;
        proxy_headers_hash_bucket_size 128;
        more_set_headers "X-Content-Type-Options: nosniff";
        more_set_headers "X-XSS-Protection: 1; mode=block";
        more_set_headers "Referrer-Policy: strict-origin-when-cross-origin";
        more_set_headers "Strict-Transport-Security: max-age=31536000; includeSubDomains; preload";
      '';

      virtualHosts = {
        "default" = {
          default = true;
          serverName = "_";
          useACMEHost = "myles.onl";
          forceSSL = true;
          locations."/" = {return = "404";};
        };

        "myles.onl" = {
          useACMEHost = "myles.onl";
          forceSSL = true;
          locations."/" = {
            return = "200 '<html><body>Hello World!</body></html>'";
            extraConfig = "default_type text/html;";
          };
        };

        "navidrome.myles.onl" = {
          useACMEHost = "myles.onl";
          forceSSL = true;
          extraConfig = ''
            proxy_buffering off;
          '';
          locations."/" = {
            proxyPass = "http://192.168.1.152:4533";
            proxyWebsockets = true;
          };
        };

        "jellyfin.myles.onl" = {
          useACMEHost = "myles.onl";
          forceSSL = true;
          extraConfig = ''
            proxy_buffering off;
          '';
          locations."/" = {
            proxyPass = "http://192.168.1.152:8096";
            proxyWebsockets = true;
          };
        };
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "mylesglanville@gmail.com";
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        environmentFile = config.sops.secrets.acme.path;
      };
      certs."myles.onl" = {
        domain = "myles.onl";
        extraDomainNames = ["*.myles.onl"];
        group = "nginx";
      };
    };
  };
}
