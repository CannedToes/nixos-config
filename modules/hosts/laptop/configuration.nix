{ self, inputs, ... }: {

  flake.nixosModules.laptop = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.laptopHardware
      self.nixosModules.base
      self.nixosModules.myles
      self.nixosModules.desktop
      self.nixosModules.firefox
      self.nixosModules.lxqt
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

    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.hostName = "laptop";

    # Enable networking
    networking.networkmanager.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
    };

    console.keyMap = "us";

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
