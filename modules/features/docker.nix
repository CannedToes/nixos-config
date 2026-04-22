{ self, inputs, ... }: {

  flake.nixosModules.docker = { pkgs, lib, ... }: {
    imports = [

    ];

    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune.enable = true;
    };

  };
}
