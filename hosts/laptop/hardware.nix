{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "sd_mod" "sr_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/mapper/luks-201514f5-0c8d-4349-b652-f4a821e7c40b";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-201514f5-0c8d-4349-b652-f4a821e7c40b".device = "/dev/disk/by-uuid/201514f5-0c8d-4349-b652-f4a821e7c40b";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FED8-C984";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
