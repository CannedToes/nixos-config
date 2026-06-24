{ inputs, ... }: {
  flake.nixosModules.nixarr = { lib, ... }: {
    imports = [
      inputs.nixarr.nixosModules.default
    ];

    nixarr = {
      enable = true;

      mediaDir = "/srv/storage/nixarr";
      stateDir = "/var/lib/nixarr";

      mediaUsers = [
        "myles"
      ];

      jellyfin = {
        enable = true;
        openFirewall = true;
      };

      seerr = {
        enable = true;
        openFirewall = true;
      };

      sonarr = {
        enable = true;
        openFirewall = true;

        settings-sync = {
          downloadClients = [
            {
              name = "qBittorrent";
              implementation = "QBittorrent";
              fields = {
                host = "127.0.0.1";
                port = 8085;
                useSsl = false;
                tvCategory = "sonarr";
                removeCompletedDownloads = true;
                removeFailedDownloads = true;
              };
            }
          ];
        };
      };

      radarr = {
        enable = true;
        openFirewall = true;

        settings-sync = {
          downloadClients = [
            {
              name = "qBittorrent";
              implementation = "QBittorrent";
              fields = {
                host = "127.0.0.1";
                port = 8085;
                useSsl = false;
                movieCategory = "radarr";
                removeCompletedDownloads = true;
                removeFailedDownloads = true;
              };
            }
          ];
        };
      };

      lidarr = {
        enable = true;
        openFirewall = true;
      };

      prowlarr = {
        enable = true;
        openFirewall = true;

        settings-sync = {
          enable-nixarr-apps = true;

          tags = [
            "torrent"
            "usenet"
            "private"
            "anime"
            "music"
          ];

          indexers = [];
        };
      };

      bazarr = {
        enable = true;
        openFirewall = true;

        settings-sync = {
          sonarr = {
            enable = true;

            config = {
              sync_only_monitored_series = true;
              sync_only_monitored_episodes = true;
            };
          };

          radarr = {
            enable = true;

            config = {
              sync_only_monitored_movies = true;
            };
          };
        };
      };

      qbittorrent = {
        enable = true;
        openFirewall = true;

        qui.enable = true;

        peerPort = 5085;
        webuiPort = 8080;

        extraConfig = {
          BitTorrent = {
            "Session\\BTProtocol" = "TCP";
            "Session\\DefaultSavePath" = "/srv/storage/nixarr/qbittorrent";
            "Session\\GlobalDLSpeedLimit" = 98304;
            "Session\\GlobalUPSpeedLimit" = 73728;
            "Session\\IgnoreSlowTorrentsForQueueing" = true;
            "Session\\MaxUploads" = 8;
            "Session\\Preallocation" = true;
            "Session\\QueuingSystemEnabled" = true;
            "Session\\ExcludedFileNames" = "*.rar\n*.r[0-9]*";
          };

          Network = {
            PortForwardingEnabled = false;
          };
        };
      };

      recyclarr = {
        enable = true;

        configuration = {
          sonarr = {
            tv = {
              base_url = "http://localhost:8989";
              api_key = "!env_var SONARR_API_KEY";

              delete_old_custom_formats = true;

              quality_profiles = [
                {
                  trash_id = "72dae194fc92bf828f32cde7744e51a1";
                  name = "1080p Balanced - Shows";

                  reset_unmatched_scores = {
                    enabled = true;
                  };
                }

                {
                  trash_id = "20e0fc959f1f1704bed501f23bdae76f";
                  name = "1080p Quality - Anime";

                  min_format_score = 0;

                  reset_unmatched_scores = {
                    enabled = true;
                  };
                }
              ];

              custom_formats = [
                {
                  trash_ids = [
                    "418f50b10f1907201b6cfdf881f467b7"
                  ];

                  assign_scores_to = [
                    {
                      name = "1080p Quality - Anime";
                      score = 2000;
                    }
                  ];
                }

                {
                  trash_ids = [
                    "b2550eb333d27b75833e25b8c2557b38"
                  ];

                  assign_scores_to = [
                    {
                      name = "1080p Quality - Anime";
                      score = 10;
                    }
                  ];
                }

                {
                  trash_ids = [
                    "026d5aadd1a6b4e550b134cb6c72b3ca"
                  ];

                  assign_scores_to = [
                    {
                      name = "1080p Quality - Anime";
                      score = 10;
                    }
                  ];
                }
              ];
            };
          };

          radarr = {
            movies = {
              base_url = "http://localhost:7878";
              api_key = "!env_var RADARR_API_KEY";

              delete_old_custom_formats = true;

              quality_profiles = [
                {
                  trash_id = "d1d67249d3890e49bc12e275d989a7e9";
                  name = "1080p Quality - Movies";

                  reset_unmatched_scores = {
                    enabled = true;
                  };
                }

                {
                  trash_id = "722b624f9af1e492284c4bc842153a38";
                  name = "1080p Quality - Anime Movies";

                  min_format_score = 0;

                  reset_unmatched_scores = {
                    enabled = true;
                  };
                }
              ];

              custom_formats = [
                {
                  trash_ids = [
                    "4a3b087eea2ce012fcc1ce319259a3be"
                  ];

                  assign_scores_to = [
                    {
                      name = "1080p Quality - Anime Movies";
                      score = 2000;
                    }
                  ];
                }

                {
                  trash_ids = [
                    "a5d148168c4506b55cf53984107c396e"
                  ];

                  assign_scores_to = [
                    {
                      name = "1080p Quality - Anime Movies";
                      score = 10;
                    }
                  ];
                }

                {
                  trash_ids = [
                    "064af5f084a0a24458cc8ecd3220f93f"
                  ];

                  assign_scores_to = [
                    {
                      name = "1080p Quality - Anime Movies";
                      score = 10;
                    }
                  ];
                }
              ];
            };
          };
        };
      };

      shelfmark = {
        enable = true;
        openFirewall = true;
        host = "0.0.0.0";
      };

      audiobookshelf = {
        enable = true;
        openFirewall = true;
        host = "0.0.0.0";
      };
    };

    services.prowlarr.settings.auth.required = "DisabledForLocalAddresses";
    services.sonarr.settings.auth.required = "DisabledForLocalAddresses";
    services.radarr.settings.auth.required = "DisabledForLocalAddresses";
    services.lidarr.settings.auth.required = "DisabledForLocalAddresses";
  };
}
