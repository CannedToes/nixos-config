{inputs, ...}: {
  flake.nixosModules.copyparty = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [inputs.copyparty.nixosModules.default];

    sops.secrets."copyparty/myles" = {
      owner = "copyparty";
    };

    services.copyparty = {
      enable = true;

      settings = {
        i = "127.0.0.1";
        no-reload = true;
        hist = "/var/cache/copyparty";
        shr = "/s";
        rproxy = -1;
      };

      accounts.myles = {
        passwordFile = config.sops.secrets."copyparty/myles".path;
      };

      volumes = {
        "/" = {
          path = "/var/lib/copyparty/data";
          access = {
            rwmd = ["myles"];
          };
        };
      };
    };

    services.nginx.virtualHosts."copyparty.myles.onl" = {
      useACMEHost = "myles.onl";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3923";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 0;
        '';
      };
    };
  };
}
