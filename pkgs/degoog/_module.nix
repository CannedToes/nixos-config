{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types mkOption mkIf mkEnableOption literalExpression getExe;

  cfg = config.services.degoog;
  srv = cfg.settings;

  degoogPackage = pkgs.callPackage ./_default.nix {};

  extensionType = types.submodule {
    options = {
      enable = mkEnableOption "this extension";
      src = mkOption {
        type = types.path;
        description = "Fetched source of the extension repo";
      };
      subpath = mkOption {
        type = types.str;
        description = "Path within src to the extension directory (e.g. plugins/weather)";
      };
    };
  };

  mkExtensionLinks = let
    cats = {inherit (cfg) plugins themes engines transports autocomplete;};
    rules = lib.flatten (lib.mapAttrsToList (
        cat: exts:
          lib.mapAttrsToList (
            name: ext:
              lib.optionalString ext.enable "L+ ${cfg.dataDir}/data/${cat}/${name} - - - - ${ext.src}/${ext.subpath}"
          )
          exts
      )
      cats);
  in
    builtins.filter (s: s != "") rules;

  writeJson = file: content: ''
    cat > "${cfg.dataDir}/data/${file}" << 'EOF'
    ${builtins.toJSON content}
    EOF
  '';
in {
  options.services.degoog = {
    enable = mkEnableOption "Degoog search aggregator";

    package = mkOption {
      type = types.package;
      default = degoogPackage;
      defaultText = literalExpression "degoogPackage";
      description = "The degoog package to use";
    };

    user = mkOption {
      type = types.str;
      default = "degoog";
      description = "User account under which degoog runs";
    };

    group = mkOption {
      type = types.str;
      default = "degoog";
      description = "Group account under which degoog runs";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/degoog";
      description = "Root directory for all on-disk state";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "File with additional environment variables (e.g. from sops-nix)";
    };

    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Domain for nginx reverse proxy";
    };

    nginx = mkOption {
      type = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Enable nginx reverse proxy for degoog";
          };
          useACMEHost = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "ACME host for TLS; defaults to the domain itself";
          };
          extraConfig = mkOption {
            type = types.lines;
            default = "";
            description = "Extra nginx location configuration";
          };
        };
      };
      default = {};
      description = "Nginx reverse proxy configuration";
    };

    settings = mkOption {
      type = types.submodule {
        options = {
          port = mkOption {
            type = types.port;
            default = 4444;
            description = "Port the server listens on";
          };

          unixSocket = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Unix domain socket path; alternative to TCP port";
          };

          baseUrl = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Base URL path when behind a reverse proxy at a sub-path";
          };

          settingsPasswordFile = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Path to a file containing DEGOOG_SETTINGS_PASSWORDS. Use with sops-nix or agenix.";
          };

          settingsPath = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Custom path for the admin settings panel";
          };

          publicInstance = mkOption {
            type = types.bool;
            default = false;
            description = "Run instance in read-only mode";
          };

          distrustProxy = mkOption {
            type = types.bool;
            default = true;
            description = "Distrust X-Forwarded-* headers; disable when behind a trusted reverse proxy";
          };

          outgoingAllowedHosts = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Allowlist of hostnames for outgoing requests";
          };

          defaultSearchLanguage = mkOption {
            type = types.str;
            default = "en-US";
            description = "Default ISO 639-1 language code applied to searches";
          };

          i18n = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Force UI locale for all requests (e.g. en-US, fr-FR)";
          };

          valkeyUrl = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Valkey/Redis connection URL for shared cache";
          };

          cacheMaxEntries = mkOption {
            type = types.int;
            default = 1000;
            description = "Maximum entries per in-memory cache namespace";
          };

          cacheTtlMs = mkOption {
            type = types.int;
            default = 43200000;
            description = "Default TTL for cached search responses (ms)";
          };

          cacheShortTtlMs = mkOption {
            type = types.int;
            default = 120000;
            description = "Short TTL for failed-engine searches (ms)";
          };

          cacheNewsTtlMs = mkOption {
            type = types.int;
            default = 1800000;
            description = "TTL for news-type search responses (ms)";
          };

          logLevel = mkOption {
            type = types.enum ["fatal" "error" "warn" "info" "log" "debug"];
            default = "info";
            description = "Server-side console output verbosity";
          };

          logTranslation = mkOption {
            type = types.bool;
            default = false;
            description = "Enable translation-specific log output";
          };

          betaStore = mkOption {
            type = types.bool;
            default = false;
            description = "Prefer develop branch of store repositories";
          };

          wizard = mkOption {
            type = types.bool;
            default = true;
            description = "Enable the first-run setup wizard";
          };
        };
      };
      default = {};
      description = "Application settings passed as environment variables to the degoog server";
    };

    plugins = mkOption {
      type = types.attrsOf extensionType;
      default = {};
      description = "Plugins from extension repositories";
    };

    themes = mkOption {
      type = types.attrsOf extensionType;
      default = {};
      description = "Themes from extension repositories";
    };

    engines = mkOption {
      type = types.attrsOf extensionType;
      default = {};
      description = "Search engines from extension repositories";
    };

    transports = mkOption {
      type = types.attrsOf extensionType;
      default = {};
      description = "Transports from extension repositories";
    };

    autocomplete = mkOption {
      type = types.attrsOf extensionType;
      default = {};
      description = "Autocomplete providers from extension repositories";
    };

    defaultEngines = mkOption {
      type = types.attrsOf types.bool;
      default = {};
      description = "Default enabled/disabled engines written to default-engines.json";
    };

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Custom bang aliases written to aliases.json";
    };

    blocklist = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Pre-seeded IP blocklist";
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts = mkIf (cfg.domain != null && cfg.nginx.enable) {
      "${cfg.domain}" = {
        useACMEHost =
          if cfg.nginx.useACMEHost != null
          then cfg.nginx.useACMEHost
          else cfg.domain;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString srv.port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_redirect off;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            ${cfg.nginx.extraConfig}
          '';
        };
      };
    };

    users.users = mkIf (cfg.user == "degoog") {
      degoog = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
        createHome = true;
      };
    };

    users.groups = mkIf (cfg.group == "degoog") {
      degoog = {};
    };

    systemd.tmpfiles.rules =
      map (d: "d ${cfg.dataDir}${d} 0700 ${cfg.user} ${cfg.group} -")
      ["" "/data" "/data/plugins" "/data/themes" "/data/engines" "/data/transports" "/data/autocomplete"]
      ++ mkExtensionLinks;

    systemd.services.degoog = {
      description = "Degoog search aggregator";
      after = ["network.target" "network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      preStart = lib.concatStringsSep "\n" (
        lib.optional (cfg.defaultEngines != {}) (writeJson "default-engines.json" cfg.defaultEngines)
        ++ lib.optional (cfg.aliases != {}) (writeJson "aliases.json" cfg.aliases)
        ++ lib.optional (cfg.blocklist != []) (writeJson "blocklist.json" cfg.blocklist)
      );

      serviceConfig =
        {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          WorkingDirectory = "${cfg.package}/share/degoog";
          ExecStart = "${getExe cfg.package}";
          Restart = "on-failure";
          RestartSec = "5s";
          StateDirectory = baseNameOf cfg.dataDir;
          StateDirectoryMode = "0700";

          NoNewPrivileges = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          MemoryDenyWriteExecute = false;
          RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
          RestrictNamespaces = true;
          LockPersonality = true;
          ReadWritePaths = [cfg.dataDir];
        }
        // lib.optionalAttrs (cfg.environmentFile != null || srv.settingsPasswordFile != null) {
          EnvironmentFile = lib.filter (f: f != null) [cfg.environmentFile srv.settingsPasswordFile];
        };

      environment = lib.filterAttrs (_: v: v != null) {
        DEGOOG_PORT = toString srv.port;
        DEGOOG_UNIX_SOCKET = srv.unixSocket;
        DEGOOG_BASE_URL = srv.baseUrl;
        DEGOOG_SETTINGS_PATH = srv.settingsPath;
        DEGOOG_PUBLIC_INSTANCE =
          if srv.publicInstance
          then "true"
          else "false";
        DEGOOG_DISTRUST_PROXY =
          if srv.distrustProxy
          then "1"
          else "0";
        DEGOOG_DEFAULT_SEARCH_LANGUAGE = srv.defaultSearchLanguage;
        DEGOOG_I18N = srv.i18n;
        DEGOOG_VALKEY_URL = srv.valkeyUrl;
        DEGOOG_CACHE_MAX_ENTRIES = toString srv.cacheMaxEntries;
        DEGOOG_CACHE_TTL_MS = toString srv.cacheTtlMs;
        DEGOOG_CACHE_SHORT_TTL_MS = toString srv.cacheShortTtlMs;
        DEGOOG_CACHE_NEWS_TTL_MS = toString srv.cacheNewsTtlMs;
        LOG_LEVEL = srv.logLevel;
        LOG_TRANSLATION =
          if srv.logTranslation
          then "true"
          else "false";
        DEGOOG_BETA_STORE =
          if srv.betaStore
          then "1"
          else "0";
        DEGOOG_WIZARD =
          if srv.wizard
          then "true"
          else "false";
        DEGOOG_DATA_DIR = "${cfg.dataDir}/data";
        DEGOOG_OUTGOING_ALLOWED_HOSTS =
          if srv.outgoingAllowedHosts != []
          then lib.concatStringsSep "," srv.outgoingAllowedHosts
          else null;
      };
    };
  };
}
