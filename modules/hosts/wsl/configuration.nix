{ self, inputs, ... }: {

  flake.nixosModules.wsl = { pkgs, lib, ... }: {
    imports = [
      inputs.nixos-wsl.nixosModules.default
      self.nixosModules.base
    ];

    networking.hostName = "wsl";

    wsl = {
      enable = true;
      defaultUser = "myles";

      wslConf.boot.systemd = true;

      interop.includePath = false;
      wslConf.interop.appendWindowsPath = false;

      wslConf.interop.enabled = true;

      wslConf.automount.options = "metadata,uid=1000,gid=1000";

      startMenuLaunchers = true;
    };

  };
}
