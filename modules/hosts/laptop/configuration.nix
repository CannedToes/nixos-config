{self, ...}: {
  flake.nixosModules.laptop = {pkgs, ...}: {
    imports = [
      # global
      self.nixosModules.system

      # host specific
      self.nixosModules.laptopHardware

      # user specific
      self.nixosModules.bluetooth
      self.nixosModules.firefox
      self.nixosModules.myles
      self.nixosModules.pipewire
      self.nixosModules.printing
      self.nixosModules.steam
    ];

    boot.plymouth.enable = true;
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

    boot.kernelPackages = pkgs.linuxPackages_zen;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    networking.hostName = "laptop";

    # Enable networking
    networking.networkmanager.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
    };

    console.keyMap = "us";
  };
}
