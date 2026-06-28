{
  inputs,
  lib,
  ...
}: let
  flaresolverrModule =
    (import ./flaresolverr-rs.nix {inherit inputs lib;}).flake.nixosModules.flaresolverr-rs;
in {
  flake.nixosModules.nixarr = {pkgs, ...}: {
    imports = [
      inputs.nixarr.nixosModules.default
      flaresolverrModule
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
              name = "Transmission";
              implementation = "Transmission";
              fields = {
                host = "127.0.0.1";
                port = 9091;
                useSsl = false;
                category = "sonarr";
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
              name = "Transmission";
              implementation = "Transmission";
              fields = {
                host = "127.0.0.1";
                port = 9091;
                useSsl = false;
                category = "radarr";
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

          indexers = [
            {
              sort_name = "1337x";
              priority = 15;
            }
            {
              sort_name = "animetosho";
              priority = 10;
              fields = {
                baseUrl = "https://feed.animetosho.org";
                apiPath = "/api";
              };
            }
            {
              sort_name = "knaben";
              priority = 40;
            }
            {
              sort_name = "limetorrents";
              priority = 25;
            }
            {
              sort_name = "nyaa si";
              priority = 5;
              fields = {
                prefer_magnet_links = true;
              };
            }
            {
              sort_name = "rutracker org";
              priority = 50;
              fields = {
                baseUrl = "https://rutracker.org/";
                username = "CannedToe";
              };
            }
            {
              sort_name = "pirate bay";
              priority = 15;
            }
            {
              sort_name = "kickasstorrents to";
              priority = 20;
            }
          ];
        };
      };

      transmission = {
        enable = true;
        openFirewall = true;

        peerPort = 5085;

        extraSettings = {
          # seed until ratio 2.0 OR 1 day idle, whichever first
          ratio-limit = 2.0;
          ratio-limit-enabled = true;
          idle-seeding-limit = 1440;
          idle-seeding-limit-enabled = true;

          # queue limits
          download-queue-size = 4;
          queue-stalled-enabled = true;
          queue-stalled-minutes = 30;

          # performance
          peer-limit-global = 200;
          peer-limit-per-torrent = 40;
          upload-slots-per-torrent = 8;
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

      recyclarr = {
        enable = true;

        configuration = {
          sonarr = {
            tv = {
              base_url = "http://localhost:8989";
              api_key = "!env_var SONARR_API_KEY";

              quality_profiles = [
                {
                  trash_id = "72dae194fc92bf828f32cde7744e51a1";
                  name = "1080p Balanced - Shows";

                  reset_unmatched_scores = {
                    enabled = true;
                  };

                  qualities = [
                    {
                      name = "WEB 1080p";
                      qualities = [
                        "WEBDL-1080p"
                        "WEBRip-1080p"
                      ];
                    }
                    {
                      name = "HDTV-1080p";
                      enabled = true;
                    }
                    {
                      name = "HDTV-720p";
                      enabled = true;
                    }
                    {
                      name = "Bluray-720p";
                      enabled = true;
                    }
                    {
                      name = "DVD";
                      enabled = true;
                    }
                  ];
                }

                {
                  trash_id = "20e0fc959f1f1704bed501f23bdae76f";
                  name = "1080p Quality - Anime";

                  min_format_score = 0;

                  reset_unmatched_scores = {
                    enabled = true;
                  };

                  qualities = [
                    {
                      name = "Bluray 1080p";
                      qualities = [
                        "Bluray-1080p"
                      ];
                    }
                    {
                      name = "WEB 1080p";
                      qualities = [
                        "WEBDL-1080p"
                        "WEBRip-1080p"
                        "HDTV-1080p"
                      ];
                    }
                    {
                      name = "Bluray-720p";
                    }
                    {
                      name = "WEB 720p";
                      qualities = [
                        "WEBDL-720p"
                        "WEBRip-720p"
                        "HDTV-720p"
                      ];
                    }
                    {
                      name = "Bluray-480p";
                    }
                    {
                      name = "WEB 480p";
                      qualities = [
                        "WEBDL-480p"
                        "WEBRip-480p"
                      ];
                    }
                    {
                      name = "DVD";
                    }
                    {
                      name = "SDTV";
                    }
                  ];
                }
              ];

              custom_format_groups = {
                add = [
                  {
                    trash_id = "85fae4a2294965b75710ef2989c850eb";
                  }
                  {
                    trash_id = "59c3af66780d08332fdc64e68297098f";
                    select = [
                      "15a05bc7c1a36e2b57fd628f8977e2fc"
                      "32b367365729d530ca1c124a0b180c64"
                      "85c61753df5da1fb2aab6f2a47426b09"
                      "fbcb31d8dabd2a319072b84fc0b7249c"
                      "9c11cd3f07101cdba90a2d81cf0e56b4"
                      "e2315f990da2e2cbfc9fa5b7a6fcfe48"
                      "23297a736ca77c0fc8e70f8edd7ee56c"
                      "e1a997ddb54e3ecbfe06341ad323c458"
                    ];
                  }
                ];
              };
            };
          };

          radarr = {
            movies = {
              base_url = "http://localhost:7878";
              api_key = "!env_var RADARR_API_KEY";

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

              custom_format_groups = {
                add = [
                  {
                    trash_id = "d9cc9a504e5ede6294c8b973aad4f028";
                  }
                  {
                    trash_id = "a3ac6af01d78e4f21fcb75f601ac96df";
                    select = [
                      "b8cd450cbfa689c0259a01d9e29ba3d6"
                      "cae4ca30163749b891686f95532519bd"
                      "b6832f586342ef70d9c128d40c07b872"
                      "cc444569854e9de0b084ab2b8b1532b2"
                      "ed38b889b31be83fda192888e2286d83"
                      "0a3f082873eb454bde444150b70253cc"
                      "e6886871085226c3da1830830146846c"
                      "90a6f9a284dff5103f6346090e6280c8"
                      "e204b80c87be9497a8a6eaff48f72905"
                      "712d74cd88bceb883ee32f773656b1f5"
                      "bfd8eb01832d646a0a89c4deb46f8564"
                    ];
                  }
                ];
              };
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

    virtualisation.podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    services.flaresolverr-rs = {
      enable = true;
      host = "127.0.0.1";
      port = 8191;
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/nixarr/secrets 0750 root prowlarr-api -"
      "f /var/lib/nixarr/secrets/prowlarr.api-key 0640 root prowlarr-api -"
      "f /var/lib/nixarr/secrets/sonarr.api-key 0640 root prowlarr-api -"
      "f /var/lib/nixarr/secrets/radarr.api-key 0640 root prowlarr-api -"
      "f /var/lib/nixarr/secrets/lidarr.api-key 0640 root prowlarr-api -"
      "f /var/lib/nixarr/secrets/bazarr.api-key 0640 root prowlarr-api -"
    ];

    services.prowlarr.settings.auth.required = "DisabledForLocalAddresses";
    services.sonarr.settings.auth.required = "DisabledForLocalAddresses";
    services.radarr.settings.auth.required = "DisabledForLocalAddresses";
    services.lidarr.settings.auth.required = "DisabledForLocalAddresses";
  };
}
