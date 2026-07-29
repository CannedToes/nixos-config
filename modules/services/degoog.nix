{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
in {
  flake.nixosModules.degoog = {
    config,
    pkgs,
    lib,
    ...
  }: let
    inherit (lib) types mkOption mkIf mkEnableOption literalExpression getExe;
    inherit (pkgs) stdenvNoCC fetchFromGitHub fetchzip bun makeWrapper;

    # bun baseline variant for CPUs without AVX
    bunBaseline = bun.overrideAttrs (old: {
      src = fetchzip {
        url = "https://github.com/oven-sh/bun/releases/download/bun-v1.3.13/bun-linux-x64-baseline.zip";
        hash = "sha256-39w4IMLFa7xLRBlMBBDASU1BhnjzR3jyswEYFysfBXo=";
      };
    });

    cfg = config.services.degoog;

    src = fetchFromGitHub {
      owner = "degoog-org";
      repo = "degoog";
      rev = "0.23.0";
      hash = "sha256-+ReSP9pMgt92E9Li9G36eQYoLuwd94ZZ9c4j/3eb068=";
    };

    bunDeps = stdenvNoCC.mkDerivation {
      pname = "degoog-bun-deps";
      version = "0.23.0";
      inherit src;

      nativeBuildInputs = [ bunBaseline ];

      buildPhase = ''
        export HOME="$TMPDIR"
        bun install --frozen-lockfile
      '';

      installPhase = ''
        mkdir -p "$out"
        cp -r node_modules "$out/"
      '';

      dontFixup = true;

      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-C61dko2C8XyuzNESGMSbCqeMNgKEwK2+/KadPlaZabg=";
    };

    degoogPackage = stdenvNoCC.mkDerivation {
      pname = "degoog";
      version = "0.23.0";
      inherit src;

      nativeBuildInputs = [ bunBaseline makeWrapper ];

      preConfigure = ''
        cp -r "${bunDeps}/node_modules" node_modules
        chmod -R +w node_modules
      '';

      configurePhase = ''
        runHook preConfigure
        runHook postConfigure
      '';

      buildPhase = ''
        runHook preBuild
        bun run build.ts
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p "$out/share/degoog" "$out/bin"
        cp -r src package.json bun.lock node_modules "$out/share/degoog/"
        rm -rf "$out/share/degoog/node_modules/.cache"
        makeWrapper ${bunBaseline}/bin/bun "$out/bin/degoog" \
          --add-flags "run $out/share/degoog/src/server/index.ts" \
          --chdir "$out/share/degoog"
        runHook postInstall
      '';

      meta = {
        description = "Self-hosted search engine aggregator with plugin support";
        homepage = "https://github.com/degoog-org/degoog";
        license = lib.licenses.agpl3Only;
        platforms = lib.platforms.linux;
        mainProgram = "degoog";
      };
    };

    extensionType = types.submodule {
      options = {
        enable = mkEnableOption "this extension";
        src = mkOption {
          type = types.path;
          description = "Fetched source of the extension repo containing this extension";
        };
        subpath = mkOption {
          type = types.str;
          description = "Path within src to the extension directory (e.g. plugins/weather)";
        };
      };
    };

    extensionDirs = {
      plugins = cfg.plugins;
      themes = cfg.themes;
      engines = cfg.engines;
      transports = cfg.transports;
      autocomplete = cfg.autocomplete;
    };

    mkExtensionLinks = let
      rules = lib.flatten (lib.mapAttrsToList (cat: exts:
        lib.mapAttrsToList (name: ext:
          lib.optionalString ext.enable
          "L+ ${cfg.dataDir}/data/${cat}/${name} - - - - ${ext.src}/${ext.subpath}"
        ) exts
      ) extensionDirs);
    in
      builtins.filter (s: s != "") rules;

  in {
    options.services.degoog = {
      enable = mkEnableOption "Degoog search aggregator";

      package = mkOption {
        type = types.package;
        default = degoogPackage;
        defaultText = literalExpression "degoogPackage";
        description = "The degoog package to use";
      };

      port = mkOption {
        type = types.port;
        default = 4444;
        description = "Port the server listens on";
      };

      unixSocket = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Unix domain socket path to listen on instead of TCP port";
      };

      baseUrl = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Base URL path when behind a reverse proxy at a sub-path";
      };

      settingsPasswords = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Passwords for the Settings page. Set at least one if exposed to the internet.";
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
        description = "Whether to distrust X-Forwarded-* headers. Set to false behind a reverse proxy you control.";
      };

      outgoingAllowedHosts = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Comma-separated allowlist of hostnames for outgoing requests";
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

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/degoog";
        description = "Root directory for all on-disk state";
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

      plugins = mkOption {
        type = types.attrsOf extensionType;
        default = {};
        description = "Plugins fetched from extension repositories";
      };

      themes = mkOption {
        type = types.attrsOf extensionType;
        default = {};
        description = "Themes fetched from extension repositories";
      };

      engines = mkOption {
        type = types.attrsOf extensionType;
        default = {};
        description = "Search engines fetched from extension repositories";
      };

      transports = mkOption {
        type = types.attrsOf extensionType;
        default = {};
        description = "Transports fetched from extension repositories";
      };

      autocomplete = mkOption {
        type = types.attrsOf extensionType;
        default = {};
        description = "Autocomplete providers fetched from extension repositories";
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

      environmentFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to environment file with additional env vars (e.g. from sops-nix)";
      };

      domain = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Domain for nginx reverse proxy";
      };

      nginx = mkOption {
        type = types.submodule {
          options = {
            enable = mkEnableOption "nginx reverse proxy for degoog" // {default = true;};
            useACMEHost = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "ACME host to use for TLS. Defaults to the domain itself.";
            };
            extraConfig = mkOption {
              type = types.lines;
              default = "";
              description = "Extra nginx location configuration";
            };
          };
        };
        default = {};
        description = "Fine-grained nginx reverse proxy settings";
      };
    };

    config = mkIf cfg.enable {
      services.nginx.virtualHosts = mkIf (cfg.domain != null && cfg.nginx.enable) {
        "${cfg.domain}" = {
          useACMEHost = if cfg.nginx.useACMEHost != null then cfg.nginx.useACMEHost else cfg.domain;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
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
        [
          "d ${cfg.dataDir} 0700 ${cfg.user} ${cfg.group} -"
          "d ${cfg.dataDir}/data 0700 ${cfg.user} ${cfg.group} -"
          "d ${cfg.dataDir}/data/plugins 0700 ${cfg.user} ${cfg.group} -"
          "d ${cfg.dataDir}/data/themes 0700 ${cfg.user} ${cfg.group} -"
          "d ${cfg.dataDir}/data/engines 0700 ${cfg.user} ${cfg.group} -"
          "d ${cfg.dataDir}/data/transports 0700 ${cfg.user} ${cfg.group} -"
          "d ${cfg.dataDir}/data/autocomplete 0700 ${cfg.user} ${cfg.group} -"
        ]
        ++ mkExtensionLinks;

      systemd.services.degoog = {
        description = "Degoog search aggregator";
        after = ["network.target" "network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];

        preStart = let
          mkWrite = path: content: ''
            cat > "${cfg.dataDir}/data/${path}" << 'EOF'
            ${builtins.toJSON content}
            EOF
          '';
          writes =
            (lib.optional (cfg.defaultEngines != {}) (mkWrite "default-engines.json" cfg.defaultEngines))
            ++ (lib.optional (cfg.aliases != {}) (mkWrite "aliases.json" cfg.aliases))
            ++ (lib.optional (cfg.blocklist != []) (mkWrite "blocklist.json" cfg.blocklist));
        in
          lib.concatStringsSep "\n" writes;

        serviceConfig = {
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
          PrivateNetwork = false;
          ReadWritePaths = [cfg.dataDir];
        } // lib.optionalAttrs (cfg.environmentFile != null) {
          EnvironmentFile = cfg.environmentFile;
        };

        environment = lib.filterAttrs (_: v: v != null && v != "") {
          DEGOOG_PORT = toString cfg.port;
          DEGOOG_UNIX_SOCKET = cfg.unixSocket;
          DEGOOG_BASE_URL = cfg.baseUrl;
          DEGOOG_SETTINGS_PASSWORDS = lib.concatStringsSep "," cfg.settingsPasswords;
          DEGOOG_SETTINGS_PATH = cfg.settingsPath;
          DEGOOG_PUBLIC_INSTANCE = if cfg.publicInstance then "true" else "false";
          DEGOOG_DISTRUST_PROXY = if cfg.distrustProxy then "1" else "0";
          DEGOOG_DEFAULT_SEARCH_LANGUAGE = cfg.defaultSearchLanguage;
          DEGOOG_I18N = cfg.i18n;
          DEGOOG_VALKEY_URL = cfg.valkeyUrl;
          DEGOOG_CACHE_MAX_ENTRIES = toString cfg.cacheMaxEntries;
          DEGOOG_CACHE_TTL_MS = toString cfg.cacheTtlMs;
          DEGOOG_CACHE_SHORT_TTL_MS = toString cfg.cacheShortTtlMs;
          DEGOOG_CACHE_NEWS_TTL_MS = toString cfg.cacheNewsTtlMs;
          LOG_LEVEL = cfg.logLevel;
          LOG_TRANSLATION = if cfg.logTranslation then "true" else "false";
          DEGOOG_BETA_STORE = if cfg.betaStore then "1" else "0";
          DEGOOG_WIZARD = if cfg.wizard then "true" else "false";
          DEGOOG_DATA_DIR = "${cfg.dataDir}/data";
          DEGOOG_OUTGOING_ALLOWED_HOSTS = if cfg.outgoingAllowedHosts != [] then lib.concatStringsSep "," cfg.outgoingAllowedHosts else null;
        };
      };
    };
  };
}
