{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.wsl = {
    pkgs,
    ...
  }: {
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
      self.nixosModules.emacs
    ];

    networking.hostName = "wsl";

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    wsl = {
      enable = true;
      defaultUser = "myles";
      useWindowsDriver = true;
      startMenuLaunchers = true;
    };
  };
}
