# -- laptop disko --
# DO NOT run `disko install` or `disko format` on this config.
# This layout is declarative only — the partitions already exist on disk.
# Running format would repartition the entire disk and WIPE Windows.
#
# partition layout:
#   nvme0n1p1  1G      EFI  WINBOOT  (Windows bootloader)
#   nvme0n1p2  16M     MSR           (Microsoft Reserved)
#   nvme0n1p3  ~198G   NTFS WINROOT  (Windows C: drive)
#   nvme0n1p4  743M    NTFS WINRE    (Windows Recovery Environment)
#   nvme0n1p5  1G      EFI  NIXBOOT  (NixOS bootloader → /boot)
#   nvme0n1p6  ~276G   LUKS NIXROOT  (NixOS root → /)
{
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            WINBOOT = {
              priority = 1;
              name = "EFI System Partition";
              size = "1G";
              type = "EF00";
              # Windows bootloader — disko does not manage this partition
            };
            MSR = {
              priority = 2;
              name = "Microsoft reserved partition";
              size = "16M";
              type = "0C01";
              # Microsoft Reserved — disko does not manage this partition
            };
            WINROOT = {
              priority = 3;
              name = "Basic data partition";
              size = "198G";
              type = "0700";
              # Windows C: drive — disko does not manage this partition
            };
            WINRE = {
              priority = 4;
              name = "WINRE";
              size = "743M";
              type = "2700";
              # Windows Recovery Environment — disko does not manage this partition
            };
            NIXBOOT = {
              priority = 5;
              name = "NIXBOOT";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["fmask=0077" "dmask=0077"];
              };
            };
            NIXROOT = {
              priority = 6;
              name = "NIXROOT";
              size = "100%";
              type = "8300";
              content = {
                type = "luks";
                name = "luks-201514f5-0c8d-4349-b652-f4a821e7c40b";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}
