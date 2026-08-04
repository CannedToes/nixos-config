{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types mkOption mkIf mkEnableOption literalExpression getExe;

  cfg = config.services.suwayomi;

  suwayomiPackage = pkgs.callPackage ./_default.nix {};

  format = pkgs.formats.hocon {};

  configFile = format.generate "server.conf" (
    lib.pipe cfg.settings [
      (
        settings:
          lib.recursiveUpdate settings {
            server.basicAuthPasswordFile = null;
            server.basicAuthPassword =
              if settings.server.basicAuthEnabled
              then "$TACHIDESK_SERVER_BASIC_AUTH_PASSWORD"
              else null;
          }
      )
      (lib.filterAttrsRecursive (_: v: v != null))
    ]
  );
in {
  options.services.suwayomi = {
    enable = mkEnableOption "Suwayomi, a free and open source manga reader server that runs extensions built for Mihon (Tachiyomi)";

    package = mkOption {
      type = types.package;
      default = suwayomiPackage;
      defaultText = literalExpression "suwayomiPackage";
      description = "The Suwayomi server package (pinned to a newer upstream release than nixpkgs)";
    };

    user = mkOption {
      type = types.str;
      default = "suwayomi";
      description = "User account under which Suwayomi runs";
    };

    group = mkOption {
      type = types.str;
      default = "suwayomi";
      description = "Group under which Suwayomi runs";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/suwayomi-server";
      description = "Root directory for Suwayomi's on-disk state";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the firewall for the configured port";
    };

    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Domain for the nginx reverse proxy";
    };

    nginx = mkOption {
      type = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Enable the nginx reverse proxy for Suwayomi";
          };
          useACMEHost = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "ACME host for TLS; defaults to the domain itself";
          };
        };
      };
      default = {};
      description = "Nginx reverse proxy configuration";
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = format.type;
        options = {
          server = {
            ip = mkOption {
              type = types.str;
              default = "0.0.0.0";
              description = "IP that Suwayomi binds to";
            };

            port = mkOption {
              type = types.port;
              default = 8080;
              description = "Port Suwayomi listens on";
            };

            basicAuthEnabled = mkEnableOption "basic access authentication for Suwayomi";

            basicAuthUsername = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Username for basic auth";
            };

            # NOTE: not a real upstream option; injects the password at runtime
            basicAuthPasswordFile = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = "File containing the basic auth password (e.g. from sops-nix)";
            };

            downloadAsCbz = mkOption {
              type = types.bool;
              default = false;
              description = "Download chapters as .cbz files";
            };

            extensionStores = mkOption {
              type = types.listOf types.str;
              default = [];
              example = ["https://github.com/keiyoushi/extensions/raw/repo/index.pb"];
              description = "URLs of extension stores (Mihon format: JSON or PROTOBUF index files)";
            };

            extensionRepos = mkOption {
              type = types.listOf types.str;
              default = [];
              description = "Deprecated: legacy extension repositories, replaced by extensionStores";
            };
          };
        };
      };
      default = {};
      description = "Configuration written to server.conf";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = with cfg.settings.server;
          basicAuthEnabled -> (basicAuthUsername != null && basicAuthPasswordFile != null);
        message = "Suwayomi: basicAuthUsername and basicAuthPasswordFile must be set when basicAuthEnabled is enabled";
      }
    ];

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [cfg.settings.server.port];

    services.nginx.virtualHosts = mkIf (cfg.domain != null && cfg.nginx.enable) {
      "${cfg.domain}" = {
        useACMEHost =
          if cfg.nginx.useACMEHost != null
          then cfg.nginx.useACMEHost
          else cfg.domain;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.settings.server.port}";
          proxyWebsockets = true;
        };
      };
    };

    users.groups = mkIf (cfg.group == "suwayomi") {
      suwayomi = {};
    };

    users.users = mkIf (cfg.user == "suwayomi") {
      suwayomi = {
        group = cfg.group;
        home = cfg.dataDir;
        description = "Suwayomi daemon user";
        isSystemUser = true;
      };
    };

    systemd.tmpfiles.settings."10-suwayomi" = {
      "${cfg.dataDir}/.local/share/Tachidesk".d = {
        mode = "0700";
        inherit (cfg) user group;
      };
    };

    systemd.services.suwayomi = {
      description = "Suwayomi manga reader server";
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
      after = ["network-online.target"];

      script = ''
        ${lib.optionalString cfg.settings.server.basicAuthEnabled ''
          export TACHIDESK_SERVER_BASIC_AUTH_PASSWORD="$(<${cfg.settings.server.basicAuthPasswordFile})"
        ''}
        ${getExe pkgs.envsubst} -i ${configFile} -o ${cfg.dataDir}/.local/share/Tachidesk/server.conf
        ${getExe cfg.package} -Dsuwayomi.tachidesk.config.server.rootDir=${cfg.dataDir}
      '';

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Type = "simple";
        Restart = "on-failure";
        StateDirectory = mkIf (cfg.dataDir == "/var/lib/suwayomi-server") "suwayomi-server";
      };
    };
  };
}
