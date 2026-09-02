{...}: {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ae97aa2c-3926-4e63-8369-7133d1199542";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/68F4-0C9D";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };
}
