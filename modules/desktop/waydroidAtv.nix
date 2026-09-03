{...}: {
  flake.nixosModules.waydroidAtv = {
    pkgs,
    lib,
    config,
    ...
  }: let
    systemUrl = "https://github.com/WayDroid-ATV/waydroid-androidtv-builds/releases/download/20260403/lineage-23.0-20260403-GAPPS-waydroid_tv_x86_64-system.zip";
    systemSha = "sha256-3fWZX5EE/nFkrTJt74u+1cv2NAtV2lAS4kC1hVxElTs=";
    vendorUrl = "https://github.com/WayDroid-ATV/waydroid-androidtv-builds/releases/download/20260403/lineage-23.0-20260403-MAINLINE-waydroid_tv_x86_64-vendor.zip";
    vendorSha = "sha256-i4sXbH07NHGYifPIkdhrmK+Nu7L3N6lw6JMC+j0M8Hc=";

    systemZip = pkgs.fetchurl {
      url = systemUrl;
      sha256 = systemSha;
    };

    vendorZip = pkgs.fetchurl {
      url = vendorUrl;
      sha256 = vendorSha;
    };

    images = pkgs.stdenv.mkDerivation {
      pname = "waydroid-atv-images";
      version = "20260403";
      nativeBuildInputs = [pkgs.unzip];
      dontUnpack = true;
      buildPhase = ''
        mkdir -p system vendor
        unzip -q ${systemZip} -d system
        unzip -q ${vendorZip} -d vendor
        mkdir -p $out
        install -m 0644 $(find system -name system.img | head -1) $out/system.img
        install -m 0644 $(find vendor -name vendor.img | head -1) $out/vendor.img
      '';
      installPhase = "true";
    };
  in {
    options.waydroidAtv = {
      images = lib.mkOption {
        type = lib.types.package;
        internal = true;
        default = images;
        description = "Waydroid ATV system and vendor images.";
      };

      baseProps = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["atv.setup.bt_remote_pairing=false"];
        description = "Android properties written to waydroid_base.prop before the container starts.";
      };
    };

    config = {
      environment.etc."waydroid-extra/images/system.img".source = "${config.waydroidAtv.images}/system.img";
      environment.etc."waydroid-extra/images/vendor.img".source = "${config.waydroidAtv.images}/vendor.img";

      systemd.services.waydroid-init = {
        description = "Initialize Waydroid";
        wantedBy = ["multi-user.target"];
        before = ["waydroid-container.service"];
        path = [pkgs.waydroid-nftables];
        unitConfig.ConditionPathExists = "!/var/lib/waydroid/waydroid.cfg";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          waydroid init -f
        '';
      };

      systemd.services.waydroid-props = {
        description = "Apply Waydroid base properties";
        wantedBy = ["multi-user.target"];
        before = ["waydroid-container.service"];
        after = ["waydroid-init.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          mkdir -p /var/lib/waydroid
          touch /var/lib/waydroid/waydroid_base.prop
          ${builtins.concatStringsSep "" (map (prop: ''
              grep -qF '${prop}' /var/lib/waydroid/waydroid_base.prop || echo '${prop}' >> /var/lib/waydroid/waydroid_base.prop
            '')
            config.waydroidAtv.baseProps)}
        '';
      };

      systemd.services.waydroid-firstrun = {
        description = "Apply Waydroid first-run Android settings";
        wantedBy = ["multi-user.target"];
        after = ["waydroid-container.service"];
        path = [pkgs.waydroid-nftables];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          for i in $(seq 1 60); do
            waydroid shell echo ok 2>/dev/null | grep -q ok && break
            sleep 5
          done
          waydroid shell settings put global device_provisioned 1 || true
          waydroid shell -- settings --user 0 put secure user_setup_complete 1 || true
          waydroid shell -- settings --user 0 put secure tv_user_setup_complete 1 || true
        '';
      };
    };
  };
}
