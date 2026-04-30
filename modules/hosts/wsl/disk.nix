{ self, inputs, ... }: {

  flake.nixosModules.wslDisk = { pkgs, lib, config, ... }: {
    fileSystems."/mnt/c" = {
      device = "C:";
      fsType = "drvfs";
      options = [
        "uid=1000"
        "gid=100"
        "umask=277"
        "noatime"
      ];
    };
    fileSystems."/srv/storage" = {
      device = "D:";
      fsType = "drvfs";
      options = [
        "uid=1000"
        "gid=997"
        "umask=002"
        "noatime"
      ];
    };
  };

}
