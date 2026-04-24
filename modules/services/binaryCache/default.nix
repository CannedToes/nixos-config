{ self, inputs, ... }: {
  flake.nixosModules.binaryCache = { pkgs, libs, config, ... }: {
    services.nix-serve = {
      package = pkgs.nix-serve-ng;
      enable = true;
      secretKeyFile = "/etc/nix/cache-priv-key.pem";
      port = 5000;
      bindAddress = "0.0.0.0";
    };

    networking.firewall.allowedTCPPorts = [
      config.services.nginx.defaultHTTPListenPort
    ];

    nix.settings.secret-key-files = [ "/etc/nix/cache-priv-key.pem" ];
  };
}
