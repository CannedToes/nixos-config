{...}: {
  flake.nixosModules.nvidia = {
    pkgs,
    config,
    ...
  }: {
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      nvidiaSettings = true;
      forceFullCompositionPipeline = false;
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [nvidia-vaapi-driver libva libva-utils];
      extraPackages32 = with pkgs.pkgsi686Linux; [nvidia-vaapi-driver libva];
    };

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };

    boot.initrd.kernelModules = ["nvidia"];
    boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11];
  };
}
