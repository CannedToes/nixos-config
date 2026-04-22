{ self, inputs, ... }: {

  flake.nixosModules.wsl = { pkgs, lib, ... }: {
    imports = [
      inputs.nixos-wsl.nixosModules.default
      self.nixosModules.base
      self.nixosModules.myles
      self.nixosModules.docker
    ];

    networking.hostName = "wsl";

    wsl = {
      enable = true;
      defaultUser = "myles";

      wslConf.boot.systemd = true;

      interop.includePath = false;
      wslConf.interop.appendWindowsPath = false;

      wslConf.interop.enabled = true;

      wslConf.automount.options = "metadata,uid=1000,gid=100";

      docker-desktop.enable = false;

      startMenuLaunchers = true;
    };
  };
}
