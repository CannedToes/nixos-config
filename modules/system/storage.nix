{ self, inputs, ... }: {

  flake.nixosModules.systemStorage = { lib, pkgs, ... }: {
    # this is only for server hosting stuff if you don't need that then ignore
    systemd.tmpfiles.rules = [
      "d /srv/data 0755 myles media -"
      "d /mnt/d 0755 myles media -"
    ];
  };

}
