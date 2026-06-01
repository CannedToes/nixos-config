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
        Address = "0.0.0.0";
        EnableInsightsCollector = true;
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

    users.users.navidrome.extraGroups = ["media"];
  };
}
