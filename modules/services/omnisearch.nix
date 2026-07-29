{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.omnisearch = {...}: {
    imports = [
      inputs.omnisearch.nixosModules.default
    ];

    services.omnisearch.enable = true;

    services.nginx = {
      virtualHosts."search.myles.onl" = {
        useACMEHost = "myles.onl";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8087";
          proxyWebsockets = true;
        };
      };
    };
  };
}
