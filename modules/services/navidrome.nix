{...}: {
  flake.nixosModules.navidrome = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets.navidrome = {};

    services.navidrome = {
      enable = true;
      openFirewall = true;
      environmentFile = config.sops.secrets.navidrome.path;

      plugins = with pkgs.navidromePlugins; [
        listenbrainz-daily-playlist
      ];

      settings = {
        Address = "127.0.0.1";
        MusicFolder = "/srv/storage/media/music";
        BaseUrl = "https://navidrome.myles.onl";
        EnableSharing = true;
        EnableGravatar = true;
        Agents = "deezer,lastfm,listenbrainz";
        LastFM.Enabled = true;
        Plugins.Enabled = true;
        Plugins.AutoReload = true;
      };
    };

    services.nginx.virtualHosts."navidrome.myles.onl" = {
      useACMEHost = "myles.onl";
      forceSSL = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:4533";
        proxyWebsockets = true;
      };
    };

    users.users.navidrome.extraGroups = ["media"];
  };
}
