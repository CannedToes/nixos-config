{...}: {
  flake.nixosModules.grafana = {
    config,
    pkgs,
    ...
  }: let
    datasource = {
      type = "prometheus";
      uid = "prometheus";
    };

    mkTarget = expr: legendFormat: {
      inherit datasource expr legendFormat;
      refId = "A";
    };

    mkTimeseries = id: title: gridPos: expr: legendFormat: unit: {
      inherit datasource gridPos id title;
      type = "timeseries";
      targets = [(mkTarget expr legendFormat)];
      fieldConfig = {
        defaults = {
          inherit unit;
          color.mode = "palette-classic";
          custom.drawStyle = "line";
        };
        overrides = [];
      };
      options = {
        legend = {
          displayMode = "list";
          placement = "bottom";
          showLegend = true;
        };
        tooltip = {
          mode = "multi";
          sort = "none";
        };
      };
    };

    mkStat = id: title: gridPos: expr: legendFormat: unit: {
      inherit datasource gridPos id title;
      type = "stat";
      targets = [(mkTarget expr legendFormat)];
      fieldConfig = {
        defaults = {
          inherit unit;
          color.mode = "thresholds";
          thresholds = {
            mode = "absolute";
            steps = [
              {
                color = "red";
                value = null;
              }
              {
                color = "green";
                value = 1;
              }
            ];
          };
        };
        overrides = [];
      };
      options = {
        colorMode = "value";
        graphMode = "area";
        justifyMode = "auto";
        orientation = "auto";
        reduceOptions = {
          calcs = ["lastNotNull"];
          fields = "";
          values = false;
        };
        textMode = "auto";
      };
    };

    dashboard = {
      uid = "nixos-observability";
      title = "NixOS Observability";
      tags = ["nixos" "prometheus"];
      timezone = "browser";
      schemaVersion = 39;
      version = 1;
      refresh = "30s";
      time = {
        from = "now-6h";
        to = "now";
      };
      panels = [
        (mkStat 1 "host availability" {
            x = 0;
            y = 0;
            w = 8;
            h = 4;
          }
          ''up{job="node"}''
          "{{host}}"
          "short")
        (mkStat 2 "nixarr exporter availability" {
            x = 8;
            y = 0;
            w = 8;
            h = 4;
          }
          ''up{job=~"nixarr-.+"}''
          "{{job}}"
          "short")
        (mkStat 3 "endpoint availability" {
            x = 16;
            y = 0;
            w = 8;
            h = 4;
          }
          ''probe_success{job="blackbox"}''
          "{{instance}}"
          "short")
        (mkTimeseries 4 "cpu usage" {
            x = 0;
            y = 4;
            w = 12;
            h = 8;
          }
          ''100 - (avg by (host) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)''
          "{{host}}"
          "percent")
        (mkTimeseries 5 "memory usage" {
            x = 12;
            y = 4;
            w = 12;
            h = 8;
          }
          ''100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)''
          "{{host}}"
          "percent")
        (mkTimeseries 6 "root disk usage" {
            x = 0;
            y = 12;
            w = 12;
            h = 8;
          }
          ''100 * (1 - node_filesystem_avail_bytes{mountpoint="/",fstype!~"tmpfs|ramfs|overlay"} / node_filesystem_size_bytes{mountpoint="/",fstype!~"tmpfs|ramfs|overlay"})''
          "{{host}}"
          "percent")
        (mkTimeseries 7 "endpoint latency" {
            x = 12;
            y = 12;
            w = 12;
            h = 8;
          }
          ''probe_duration_seconds{job="blackbox"}''
          "{{instance}}"
          "s")
        (mkTimeseries 8 "nginx requests" {
            x = 0;
            y = 20;
            w = 12;
            h = 8;
          }
          ''sum(rate(nginx_http_requests_total[5m]))''
          "requests/s"
          "reqps")
        (mkTimeseries 9 "postgres database size" {
            x = 12;
            y = 20;
            w = 12;
            h = 8;
          }
          ''pg_database_size_bytes{datname!~"template.*"}''
          "{{datname}}"
          "bytes")
        (mkTimeseries 10 "exporter availability" {
            x = 0;
            y = 28;
            w = 24;
            h = 8;
          }
          ''up{job=~"systemd|nginx|postgres|nixarr-.+"}''
          "{{job}} {{host}} {{instance}}"
          "short")
      ];
    };

    dashboardDir = pkgs.writeTextDir "nixos-observability.json" (builtins.toJSON dashboard);
  in {
    sops.secrets = {
      "grafana/admin-password".owner = "grafana";
      "grafana/secret-key".owner = "grafana";
    };

    networking.hosts."127.0.0.1" = ["grafana.myles.onl"];

    services.grafana = {
      enable = true;

      settings = {
        analytics.reporting_enabled = false;
        security = {
          admin_user = "admin";
          admin_password = "$__file{${config.sops.secrets."grafana/admin-password".path}}";
          secret_key = "$__file{${config.sops.secrets."grafana/secret-key".path}}";
        };
        server = {
          domain = "grafana.myles.onl";
          http_addr = "127.0.0.1";
          http_port = 3000;
          root_url = "https://grafana.myles.onl/";
        };
        users.allow_sign_up = false;
      };

      provision = {
        enable = true;
        datasources.settings = {
          apiVersion = 1;
          prune = true;
          datasources = [
            {
              inherit (datasource) type uid;
              name = "Prometheus";
              access = "proxy";
              url = "http://127.0.0.1:9090";
              isDefault = true;
              editable = false;
              jsonData.timeInterval = "30s";
            }
          ];
        };
        dashboards.settings = {
          apiVersion = 1;
          providers = [
            {
              name = "nixos";
              options.path = dashboardDir;
            }
          ];
        };
      };
    };

    services.nginx.virtualHosts."grafana.myles.onl" = {
      useACMEHost = "myles.onl";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
      };
    };
  };
}
