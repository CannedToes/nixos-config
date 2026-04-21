{ self, inputs, ... }: {

  flake.nixosModules.desktop = { pkgs, lib, ... }: {
    environment.systemPackages = with pkgs; [
    	feishin
    ];
  };

}
