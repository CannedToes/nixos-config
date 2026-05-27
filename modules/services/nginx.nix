<<<<<<< HEAD
{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.nginx = {
    pkgs,
    lib,
    config,
    ...
  }: {
    # manual firewalling
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    networking.firewall.allowedUDPPorts = [
      443
    ];

    # nginx
    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."myles.onl" = {
        useACMEHost = "myles.onl";
        forceSSL = true;
        locations."/" = {
          return = "200 '<html><body>Hello World!</body></html>'";
          extraConfig = ''
            default_type text/html;
          '';
        };
      };
      virtualHosts."navidrome.myles.onl" = {
        useACMEHost = "myles.onl";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://192.168.1.152:4533";
          proxyWebsockets = true;
        };
      };
    };

    # acme certs
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "mylesglanville@gmail.com";
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        environmentFile = config.sops.secrets.acme.path;
      };
      certs = {
        "myles.onl" = {
          domain = "myles.onl";
          extraDomainNames = ["*.myles.onl"];
          group = "nginx";
        };
||||||| (empty tree)
=======
{...}: {
  flake.nixosModules.nginx = {config, ...}: {
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

      commonHttpConfig = ''
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
        add_header X-Content-Type-Options "nosniff";
        add_header X-XSS-Protection "1; mode=block";
        add_header Referrer-Policy "strict-origin-when-cross-origin";
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
      '';

      virtualHosts."default" = {
        default = true;
        serverName = "_";
        useACMEHost = "myles.onl";
        forceSSL = true;
        locations."/" = {return = "404";};
      };

      virtualHosts."myles.onl" = {
        useACMEHost = "myles.onl";
        forceSSL = true;
        locations."/" = {
          return = "200 '<html><body>Hello World!</body></html>'";
          extraConfig = "default_type text/html;";
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
>>>>>>> 8a283fc (GINEMINANORMOUS REFACTOR)
      };
    };
  };
}
