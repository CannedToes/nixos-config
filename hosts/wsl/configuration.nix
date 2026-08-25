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

      # -- hardware --
      graphics

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

        boot.extraModprobeConfig = "options kvm_amd nested=1";

        systemd.services.kvm-wsl = {
          description = "Load KVM modules and set /dev/kvm permissions";
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = pkgs.writeShellScript "load-kvm" ''
              ${pkgs.kmod}/bin/modprobe kvm
              ${pkgs.kmod}/bin/modprobe kvm_amd
              chown root:kvm /dev/kvm
              chmod 0660 /dev/kvm
            '';
          };
        };

        users.groups.kvm = {};
        users.users.myles.extraGroups = ["kvm" "libvirtd"];

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
