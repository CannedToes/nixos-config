{...}: {
  flake.nixosModules.suwayomi = {config, ...}: {
    imports = [
      ../../pkgs/suwayomi/_module.nix
    ];

    sops.secrets."suwayomi/password" = {
      owner = "suwayomi";
      group = "suwayomi";
      mode = "0400";
    };

    services.suwayomi = {
      enable = true;
      openFirewall = true;
      domain = "suwayomi.myles.onl";
      nginx.useACMEHost = "myles.onl";

      settings.server = {
        port = 4567;

        basicAuthEnabled = true;
        basicAuthUsername = "suwayomi";
        basicAuthPasswordFile = config.sops.secrets."suwayomi/password".path;

        downloadAsCbz = true;

        extensionStores = [
          "https://github.com/yuzono/manga-repo/raw/repo/index.pb"
          "https://github.com/yuzono/cursed-manga-repo/raw/repo/index.pb"
        ];
      };
    };
  };
}
