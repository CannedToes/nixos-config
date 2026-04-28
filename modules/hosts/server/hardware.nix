{ self, inputs, ... }: {

  flake.nixosModules.serverHardware = { lib, pkgs, ... }: {
    imports = [
      # import other NixOS-Hardware modules (as in the flake repo) if wanted i guess
    ];

    hardware.facter.reportPath = ./facter.json;

  };

}
