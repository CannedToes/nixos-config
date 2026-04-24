{ self, inputs, ... }: {

  flake.nixosModules.wsl = { pkgs, lib, ... }: {
    imports = [
      inputs.nixos-wsl.nixosModules.default
      inputs.sops-nix.nixosModules.sops
      self.nixosModules.base
      self.nixosModules.myles
      self.nixosModules.binaryCache
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

      startMenuLaunchers = true;
    };
  };
}
