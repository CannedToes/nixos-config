{ self, inputs, ... }: {

  flake.nixosModules.wsl = { pkgs, lib, ... }: {
    imports = [
      # global
      self.nixosModules.system

      # host specific
      inputs.nixos-wsl.nixosModules.default
      inputs.sops-nix.nixosModules.sops
      self.nixosModules.wslPackages

      # user specific
      self.nixosModules.myles
    ];

    networking.hostName = "wsl";

    environment.variables = {
      BROWSER = "explorer.exe";
    };

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
