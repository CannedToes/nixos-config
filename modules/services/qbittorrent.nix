{...}: {
  flake.nixosModules.qbittorrent = {...}: {
    services.qbittorrent = {
      enable = true;
      openFirewall = true;
      serverConfig = {
        LegalNotice.Accepted = true;

        BitTorrent.Session = {
          AlternativeGlobalDLSpeedLimit = 0;
          AlternativeGlobalUPSpeedLimit = 0;
          BTProtocol = "TCP";
          BandwidthSchedulerEnabled = true;
          DefaultSavePath = "/srv/storage/torrents";
          DisableAutoTMMByDefault = false;
          DisableAutoTMMTriggers = {
            CategorySavePathChanged = false;
            DefaultSavePathChanged = false;
          };
          ExcludedFileNames = "";
          GlobalDLSpeedLimit = 98304;
          GlobalUPSpeedLimit = 73728;
          IgnoreSlowTorrentsForQueueing = true;
          MaxUploads = 8;
          Port = 5085;
          Preallocation = true;
          QueuingSystemEnabled = true;
          UseAlternativeGlobalSpeedLimit = false;
        };

        Core.AutoDeleteAddedTorrentFile = "IfAdded";

        Network.PortForwardingEnabled = false;

        Preferences = {
          General.Locale = "en";
          MailNotifcation.req_auth = true;
          Scheduler = {
            end_time = ''@Variant(\0\0\0\xf\x1I\x97\0)'';
            start_time = ''@Variant(\0\0\0\xf\xff\xff\xff\xff)'';
          };
          WebUI = {
            AuthSubnetWhitelist = "192.168.1.0/24";
            AuthSubnetWhitelistEnabled = true;
            ClickjackingProtection = false;
            LocalHostAuth = false;
          };
        };
      };
    };

    users.users.qbittorrent.extraGroups = ["media"];

    systemd.services.qbittorrent = {
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };
  };
}
