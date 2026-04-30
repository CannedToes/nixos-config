{ self, inputs, ... }: {

  flake.nixosModules.wsl = { pkgs, lib, ... }: {
    imports = [
      # global options
      self.nixosModules.system

      # host specific
      inputs.nixos-wsl.nixosModules.default
      self.nixosModules.wslDisk
      self.nixosModules.wslPackages
      self.nixosModules.wslServices

      # user specific
      self.nixosModules.myles
    ];

    networking.hostName = "wsl";

    wsl = {
      enable = true;
      defaultUser = "myles";

      useWindowsDriver = true;

      startMenuLaunchers = true;

      wslConf.boot.systemd = true;

      interop.includePath = false;
      wslConf.interop.appendWindowsPath = false;
      wslConf.interop.enabled = true;

      wslConf.automount.enabled = false;
      wslConf.automount.options = "uid=1000,gid=997,noatime";
    };
  };

}
