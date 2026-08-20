{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = with self.nixosModules; [
      # -- system --
      locale
      networking
      nix
      sops
      users

      # -- programs --
      cli
      dev

      # -- wslg --
      fonts

      # -- wsl --
      inputs.nixos-wsl.nixosModules.default

      # -- host configuration --
      ({pkgs, ...}: {
        sops.defaultSopsFile = ./secrets.yaml;

        boot.kernelModules = ["kvm" "kvm_amd"];
        boot.extraModprobeConfig = "options kvm_amd nested=1";

        virtualisation.libvirtd = {
          enable = true;
          qemu = {
            package = pkgs.qemu_kvm;
            runAsRoot = true;
            swtpm.enable = true;
          };
        };

        programs.virt-manager.enable = true;

        networking.hostName = "wsl";

        networking.dhcpcd.enable = false;
        networking.firewall.trustedInterfaces = ["lo"];
        networking.networkmanager.enable = false;

        systemd.network.enable = false;
        systemd.services.systemd-resolved.enable = false;
        systemd.services.systemd-udevd.enable = false;

        nixpkgs.overlays = [inputs.emacs-overlay.overlays.default];

        programs.fuse = {
          enable = true;
        };

        hardware.graphics.enable = true;
        hardware.graphics.enable32Bit = true;

        wsl = {
          enable = true;
          defaultUser = "myles";
          startMenuLaunchers = true;
          wslConf = {
            automount.enabled = false;
            interop.appendWindowsPath = false;
            network.generateResolvConf = false;
          };
        };
      })
    ];
  };

  perSystem = {...}: {
    packages.wsl = self.nixosConfigurations.wsl.config.system.build.toplevel;
  };
}
