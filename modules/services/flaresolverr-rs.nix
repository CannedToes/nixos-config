{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.flaresolverr-rs = {
    pkgs,
    config,
    ...
  }: let
    cfg = config.services.flaresolverr-rs;

    pkg = pkgs.rustPlatform.buildRustPackage {
      pname = "flaresolverr-rs";
      version = "0.2.2";

      src = inputs.flaresolverr-rs;

      cargoLock.lockFile = "${inputs.flaresolverr-rs}/Cargo.lock";

      nativeBuildInputs = [pkgs.pkg-config];

      buildInputs = [pkgs.openssl];

      meta = with lib; {
        description = "FlareSolverr Rust Port — Cloudflare bypass as an HTTP proxy";
        homepage = "https://github.com/eben0/flaresolverr-rs";
        license = licenses.mit;
        maintainers = [];
        mainProgram = "flaresolverr-rs";
        platforms = platforms.linux;
      };
    };
  in {
    options.services.flaresolverr-rs = {
      enable = lib.mkEnableOption "flaresolverr-rs Cloudflare bypass proxy";

      port = lib.mkOption {
        type = lib.types.port;
        default = 8191;
        description = "Port for flaresolverr-rs to listen on";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Address to bind to";
      };

      logLevel = lib.mkOption {
        type = lib.types.enum ["trace" "debug" "info" "warn" "error"];
        default = "info";
        description = "Log level";
      };

      maxTimeoutMs = lib.mkOption {
        type = lib.types.ints.positive;
        default = 120000;
        description = "Maximum timeout in milliseconds for requests";
      };

      contextLimit = lib.mkOption {
        type = lib.types.ints.positive;
        default = 20;
        description = "Maximum concurrent Chrome contexts";
      };

      headless = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Run Chrome in headless mode";
      };

      virtualDisplay = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Use virtual display (needed on headless Linux without headless mode)";
      };
    };

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [pkg pkgs.chromium];

      systemd.services.flaresolverr-rs = {
        description = "flaresolverr-rs Cloudflare bypass proxy";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        path = [pkgs.chromium];

        serviceConfig = {
          ExecStart = "${pkg}/bin/flaresolverr-rs";
          Restart = "always";
          RestartSec = 5;
          DynamicUser = true;
          PrivateTmp = true;
          Environment = [
            "FLARESOLVERR_HOST=${cfg.host}"
            "FLARESOLVERR_PORT=${toString cfg.port}"
            "FLARESOLVERR_LOG_LEVEL=${cfg.logLevel}"
            "FLARESOLVERR_MAX_TIMEOUT_MS=${toString cfg.maxTimeoutMs}"
            "FLARESOLVERR_CONTEXT_LIMIT=${toString cfg.contextLimit}"
            "FLARESOLVERR_HEADLESS=${
              if cfg.headless
              then "true"
              else "false"
            }"
            "FLARESOLVERR_VIRTUAL_DISPLAY=${
              if cfg.virtualDisplay
              then "true"
              else "false"
            }"
            "CHROME_PATH=${pkgs.chromium}/bin/chromium"
            "CHROME_BIN=${pkgs.chromium}/bin/chromium"
          ];
        };
      };
    };
  };
}
