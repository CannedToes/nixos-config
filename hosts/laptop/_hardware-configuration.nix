{...}: {
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
}
