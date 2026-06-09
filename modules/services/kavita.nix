{...}: {
  flake.nixosModules.kavita = {pkgs, ...}: {
    services.kavita = {
      enable = true;
      tokenKeyFile = "/var/lib/kavita/token-key";
      settings = {
        IpAddresses = "127.0.0.1";
        Port = 5000;
      };
    };

    users.users.kavita.extraGroups = ["media"];

    systemd.services.kavita-token-key = {
      description = "Generate Kavita token key";
      before = ["kavita.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.coreutils}/bin/install -d -m 0750 -o kavita -g kavita /var/lib/kavita
        if [ ! -s /var/lib/kavita/token-key ]; then
          umask 0077
          ${pkgs.coreutils}/bin/head -c 64 /dev/urandom | ${pkgs.coreutils}/bin/base64 --wrap=0 > /var/lib/kavita/token-key
        fi
        ${pkgs.coreutils}/bin/chown kavita:kavita /var/lib/kavita/token-key
        ${pkgs.coreutils}/bin/chmod 0600 /var/lib/kavita/token-key
      '';
    };

    systemd.services.kavita = {
      requires = ["kavita-token-key.service"];
      after = ["kavita-token-key.service"];
    };

    services.nginx.virtualHosts."kavita.myles.onl" = {
      useACMEHost = "myles.onl";
      forceSSL = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:5000";
        proxyWebsockets = true;
      };
    };
  };
}
