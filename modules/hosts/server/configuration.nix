{ self, inputs, ... }: {

  flake.nixosModules.server = { pkgs, lib, ... }: {
    imports = [
      # global
      self.nixosModules.system

      # host specific
      self.nixosModules.serverDisko
      self.nixosModules.serverFirewall
      self.nixosModules.serverHardware

      # user specific
      self.nixosModules.myles
    ];

    boot.loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
      };
    };

    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.hostName = "server";

    networking.networkmanager.enable = true;
  };

}
