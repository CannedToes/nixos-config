{inputs, ...}: {
  flake.nixosModules.persistence = {
    config,
    lib,
    username,
    ...
  }: let
    cfg = config.my.persistence;
    systemRoot = "${cfg.root}/system";
    userDataRoot = "${cfg.root}/userdata";
    userCacheRoot = "${cfg.root}/usercache";
  in {
    imports = [
      inputs.impermanence.nixosModules.impermanence
    ];

    options.my.persistence = {
      enable = lib.mkEnableOption "persistent state bind mounts";

      root = lib.mkOption {
        type = lib.types.str;
        default = "/persist";
        description = "Persistent filesystem mountpoint used by impermanence.";
      };

      desktop.enable = lib.mkEnableOption "desktop-oriented persisted state";
      server.enable = lib.mkEnableOption "server service persisted state";

      directories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Extra system directories to persist.";
      };

      files = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Extra system files to persist.";
      };

      userDirectories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Extra durable directories in the main user's home to persist.";
      };

      userFiles = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Extra durable files in the main user's home to persist.";
      };

      userCacheDirectories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Extra cache-like directories in the main user's home to persist separately.";
      };

      userCacheFiles = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Extra cache-like files in the main user's home to persist separately.";
      };
    };

    config = lib.mkIf cfg.enable {
      programs.fuse.userAllowOther = true;
      boot.tmp.cleanOnBoot = lib.mkDefault true;

      environment.persistence = {
        ${systemRoot} = {
          hideMounts = true;

          directories =
            [
              "/etc/ssh"
              "/var/lib/nixos"
              "/var/lib/sops-nix"
              "/var/lib/systemd"
              "/var/log"
            ]
            ++ lib.optionals cfg.desktop.enable [
              "/etc/NetworkManager/system-connections"
              "/var/lib/bluetooth"
              "/var/lib/cups"
            ]
            ++ lib.optionals cfg.server.enable [
              "/var/lib/acme"
              "/var/lib/containers"
              "/var/lib/haos"
              "/var/lib/home-assistant"
              "/var/lib/kavita"
              "/var/lib/matrix-synapse"
              "/var/lib/ntfy-sh"
              "/var/lib/postgresql"
              "/var/lib/private"
              "/var/lib/prosody"
              "/var/lib/radicale"
              "/var/lib/vaultwarden"
            ]
            ++ cfg.directories;

          files =
            [
              "/etc/machine-id"
            ]
            ++ cfg.files;
        };

        ${userDataRoot}.users.${username} = {
          directories =
            [
              ".local/share/zoxide"
              ".ssh"
            ]
            ++ cfg.userDirectories;
          files = cfg.userFiles;
        };

        ${userCacheRoot}.users.${username} = {
          directories =
            [
              ".cache/nix"
              ".local/share/direnv"
              ".local/state/nvim"
            ]
            ++ cfg.userCacheDirectories;
          files = cfg.userCacheFiles;
        };
      };
    };
  };
}
