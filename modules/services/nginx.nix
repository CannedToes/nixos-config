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
      };
    };
  };
}
