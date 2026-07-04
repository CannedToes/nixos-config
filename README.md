# nixos-config

personal nixos flake for my desktop, laptop, server, and wsl environments.
uses `flake-parts` with auto-imported modules via `importTree`.

## hosts
- **desktop** - amd + nvidia, cachyos kernel, plymouth, grub, sway
- **laptop** - amd mobile, zen kernel, tlp power management, sway
- **server** - headless, disko lvm, systemd-boot, nginx
- **wsl** - nixos-wsl, drvfs mounts

## features

- **dendritic** - as mentioned before it uses flake-parts and importTree to effortlessly modularize config (wow)
- **secrets** - sops-nix with age encryption, per-host secret files
- **auto-import** - any `.nix` file in is auto-loaded (prefixed `_` excluded)
- **formatting** - alejandra via treefmt-nix (`nix fmt`)

## try a profile

build and run any host in a vm:

```sh
nix build .#laptop-vm
result/bin/run-laptop-vm
```

available vm profiles: `desktop-vm`, `laptop-vm`, `server-vm`.

## disclaimer

this is my personal config. it is not designed to be cloned and directly
adapted. host configs reference specific hardware, secrets, and local state.
