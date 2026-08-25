{...}: {
  flake.nixosModules.jellyfin = {pkgs, ...}: {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      hardwareAcceleration = {
        enable = true;
        device = "/dev/dri/renderD128";
        type = "vaapi";
      };
      forceEncodingConfig = true;
      transcoding = {
        maxConcurrentStreams = 3;
        throttleTranscoding = true;
        enableToneMapping = false;
        enableHardwareEncoding = true;
        enableIntelLowPowerEncoding = true;
        hardwareDecodingCodecs = {
          h264 = true;
          hevc = true;
          vp9 = true;
        };
        hardwareEncodingCodecs = {
          hevc = true;
        };
      };
    };

    services.nginx.virtualHosts."jellyfin.myles.onl" = {
      useACMEHost = "myles.onl";
      forceSSL = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
      };
    };

    users.users.jellyfin.extraGroups = ["media"];
  };
}
