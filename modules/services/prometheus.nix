{...}: {
  flake.nixosModules.prometheus = {
    config,
    pkgs,
    ...
  }: let
    serverIp = "192.168.1.158";
    wslIp = "192.168.1.153";

    blackboxConfig = (pkgs.formats.yaml {}).generate "blackbox.yml" {
      modules.http_2xx = {
        prober = "http";
        timeout = "5s";
        http = {
          follow_redirects = true;
          preferred_ip_protocol = "ip4";
          valid_http_versions = ["HTTP/1.1" "HTTP/2.0"];
        };
      };
    };

    endpoints = [
      "https://myles.onl"
      "https://home.myles.onl"
      "https://ntfy.myles.onl"
      "https://search.myles.onl"
      "https://vault.myles.onl"
      "https://jellyfin.myles.onl"
      "https://navidrome.myles.onl"
      "https://grafana.myles.onl"
    ];

    nodePort = toString config.services.prometheus.exporters.node.port;
    systemdPort = toString config.services.prometheus.exporters.systemd.port;
    nginxPort = toString config.services.prometheus.exporters.nginx.port;
    postgresPort = toString config.services.prometheus.exporters.postgres.port;
    blackboxPort = toString config.services.prometheus.exporters.blackbox.port;
  in {
    services.nginx.statusPage = true;

    services.prometheus = {
      enable = true;
      enableReload = true;
      listenAddress = "127.0.0.1";
      retentionTime = "30d";

      exporters = {
        node = {
          enable = true;
          listenAddress = "0.0.0.0";
          enabledCollectors = ["systemd" "tcpstat" "network_route"];
        };

        systemd = {
          enable = true;
          listenAddress = "0.0.0.0";
        };

        blackbox = {
          enable = true;
          listenAddress = "127.0.0.1";
          configFile = blackboxConfig;
        };

        nginx = {
          enable = true;
          listenAddress = "127.0.0.1";
          scrapeUri = "http://127.0.0.1/nginx_status";
        };

        postgres = {
          enable = true;
          listenAddress = "127.0.0.1";
          runAsLocalSuperUser = true;
        };
      };

      globalConfig = {
        scrape_interval = "30s";
        evaluation_interval = "30s";
      };

      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = ["${serverIp}:${nodePort}"];
              labels.host = "server";
            }
            {
              targets = ["${wslIp}:${nodePort}"];
              labels.host = "wsl";
            }
          ];
        }
        {
          job_name = "systemd";
          static_configs = [
            {
              targets = ["${serverIp}:${systemdPort}"];
              labels.host = "server";
            }
            {
              targets = ["${wslIp}:${systemdPort}"];
              labels.host = "wsl";
            }
          ];
        }
        {
          job_name = "nginx";
          static_configs = [
            {
              targets = ["127.0.0.1:${nginxPort}"];
              labels.host = "server";
            }
          ];
        }
        {
          job_name = "postgres";
          static_configs = [
            {
              targets = ["127.0.0.1:${postgresPort}"];
              labels.host = "server";
            }
          ];
        }
        {
          job_name = "blackbox";
          metrics_path = "/probe";
          params.module = ["http_2xx"];
          static_configs = [
            {targets = endpoints;}
          ];
          relabel_configs = [
            {
              source_labels = ["__address__"];
              target_label = "__param_target";
            }
            {
              source_labels = ["__param_target"];
              target_label = "instance";
            }
            {
              target_label = "__address__";
              replacement = "127.0.0.1:${blackboxPort}";
            }
          ];
        }
        {
          job_name = "nixarr-sonarr";
          static_configs = [{targets = ["${wslIp}:9707"];}];
        }
        {
          job_name = "nixarr-radarr";
          static_configs = [{targets = ["${wslIp}:9708"];}];
        }
        {
          job_name = "nixarr-lidarr";
          static_configs = [{targets = ["${wslIp}:9709"];}];
        }
        {
          job_name = "nixarr-prowlarr";
          static_configs = [{targets = ["${wslIp}:9711"];}];
        }
        {
          job_name = "nixarr-qbittorrent";
          static_configs = [{targets = ["${wslIp}:9713"];}];
        }
      ];
    };

    systemd.services.prometheus-postgres-exporter = {
      after = ["postgresql.service"];
      requires = ["postgresql.service"];
    };
  };
}
