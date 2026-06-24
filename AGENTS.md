# nixos-config

NixOS flake using `flake-parts` with auto-imported modules via `importTree`.

## ethos

This repo values simplicity, readability, and maintainability above all else.
Every addition should be questioned: is this necessary? can it be simpler?

- **comments**: minimize them. only add when the code cannot make itself clear
  through context. when you do comment, use lowercase, no punctuation at the end.
  section headings inside a module: `-- heading --`
- **prefer native nixpkgs**: use the built-in `services.*` modules over wrapping
  things in containers (podman/docker). containers are a last resort when
  nixpkgs has no native module for what you need.
- **consistency**: any new code should mirror the style and patterns of existing
  modules in the repo. read the neighbors first.
- **free open source**: prefer FOSS tooling at every point. only reach for
  non-free when there is no viable alternative.
- **when unsure, ask**: don't guess conventions or make assumptions. come back
  and ask before committing to an approach.

## hosts

- `desktop` — amd + nvidia gaming/workstation (cachyos kernel, plymouth, grub)
- `laptop` — amd laptop (zen kernel, tlp, nixos-facter, plymouth, grub)
- `server` — headless (disko lvm, systemd-boot, nixos-facter, nginx, monitoring)
- `wsl` — wsl2 (nixos-wsl, drvfs mounts, nixarr/media)

## module system

Every `.nix` file in the repo (except `flake.nix` and files starting with `_`) is
auto-imported via `importTree` in `flake.nix`. Each module self-registers:

```nix
{...}: {
  flake.nixosModules.<name> = {pkgs, ...}: { ... };
}
```

Host configs reference modules via `self.nixosModules.<name>`.

Files prefixed with `_` (e.g., `_disko.nix`, `_hardware-configuration.nix`) are
excluded from auto-import and must be referenced explicitly by path.

## commands

```sh
nix fmt                    # format with alejandra (via treefmt-nix)
nix flake check            # check evaluation of all outputs
nix build .#<host>         # build toplevel (desktop, laptop, server, wsl)
nix build .#<host>-vm      # build test vm (desktop, laptop, server)
result/bin/run-<host>-vm   # run the vm after building
```

## secrets

Managed by `sops-nix`. Per-host files at `hosts/<host>/secrets.yaml`.
Age key rules in `.sops.yaml`. Each host config sets `sops.defaultSopsFile`.

## quirks

- **state version**: `26.05`. keep in sync when adding new modules.
- **hardware detection**: uses `nixos-facter` on laptop and server.
  `hosts/laptop/facter.json` and `hosts/server/facter.json`.
- **disko**: server uses disko for disk partitioning. see `hosts/server/_disko.nix`.
- **kernel overlays**: desktop uses `nix-cachyos-kernel` overlay.
- **vm testing**: the `-vm` packages build a qemu vm of each host for testing.
  some hosts have `virtualisation.vmVariant` with custom spice/vnc config.

## key flake inputs

`nixpkgs` (unstable), `sops-nix`, `disko`, `nixos-hardware`, `nixos-facter`,
`nix-cachyos-kernel`, `nixos-wsl`, `impermanence`, `nixarr`, `treefmt-nix`.
