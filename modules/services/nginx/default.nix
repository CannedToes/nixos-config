{ self, inputs, ... }: {

  flake.nixosModules.nginx = { pkgs, libs, config, ... }: {
    # manual firewalling
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    # nginx
    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."myles.onl" =  {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          return = "200 '<html><body>Hello World!</body></html>'";
          extraConfig = ''
            default_type text/html;
          '';
        };
      };
      virtualHosts."navidrome.myles.onl" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://192.168.1.152:4533";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };

    # acme certs
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "mylesglanville@gmail.com";
        dnsProviders = "cloudflare";
        environmentFile = "${config.age.secrets.cloudflare_acme.path}";
      };
    };
  };

}
