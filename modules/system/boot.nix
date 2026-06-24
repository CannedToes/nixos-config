{...}: {
  flake.nixosModules.boot = {...}: {
    boot = {
      loader = {
        efi.canTouchEfiVariables = true;
        efi.efiSysMountPoint = "/boot";
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
          gfxpayloadEfi = "keep";
          useOSProber = true;
        };
      };
      plymouth.enable = true;
      supportedFilesystems = ["ntfs"];
    };
  };
}
