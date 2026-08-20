{inputs, ...}: {
  flake.nixosModules.sops = {pkgs, ...}: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops.age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    sops.useSystemdActivation = true;

    environment.systemPackages = [pkgs.sops];
  };
}
