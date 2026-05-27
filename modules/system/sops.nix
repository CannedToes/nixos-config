<<<<<<< HEAD
{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.systemSops = {
    pkgs,
    lib,
    config,
    ...
  }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    # the path to your sops secrets file that will actually hold all the secrets (not .sops.yaml which is for sops management)
    sops.defaultSopsFile = ../../secrets/secrets.yaml;

    # this will automatically import your ssh keys as age keys into sops
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    # the path to your age key that is expected to already be in the filesystem
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";

    # this will generate a new key if the key specified above does not exist
    sops.age.generateKey = true;

    # the specifications for all your secrets
    sops.secrets.acme = {};

    sops.secrets."ddclient/cloudflare" = {};

    sops.secrets."myles/password" = {};

    sops.secrets.navidrome = {};
||||||| (empty tree)
=======
# -- SOPS default configuration --
# Each host sets its own defaultSopsFile pointing to ./secrets.yaml in its host directory.
# Secret declarations live in the modules that use them (e.g. navidrome.nix declares
# sops.secrets.navidrome, users.nix declares sops.secrets."myles/password").
{inputs, ...}: {
  flake.nixosModules.sops = {...}: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    sops.age.generateKey = true;
>>>>>>> 8a283fc (GINEMINANORMOUS REFACTOR)
  };
}
