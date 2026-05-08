{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.grafana = {
    pkgs,
    lib,
    config,
    ...
  }: {
    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 3000;
          enable_gzip = true;
          domain = "grafana.myles.onl";
        };
      };
    };
    # services.nginx.virtualHosts."grafana.myles.onl" = {
    #   addSSL = true;
    #   ACMEHost = "myles.onl";
    #   locations."/" = {
    #     proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
    #     proxyWebsockets = true;
    #   };
    # };
  };
}
