{ self, inputs, ... }: {
  flake.nixosModules.systemSops = { pkgs, lib, config, ... }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    # the path to your sops secrets file that will actually hold all the secrets (not .sops.yaml which is for sops management)
    sops.defaultSopsFile = ../../secrets/secrets.yaml;

    # this will automatically import your ssh keys as age keys into sops
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # the path to your age key that is expected to already be in the filesystem
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";

    # this will generate a new key if the key specified above does not exist
    sops.age.generateKey = true;

    # the specifications for all your secrets
    sops.secrets."acme/cloudflare" = {};
    sops.secrets."ddclient/cloudflare" = {};
    sops.secrets."myles/password" = {};
  };
}
