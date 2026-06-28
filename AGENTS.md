# nixos-config

NixOS flake using `flake-parts` with auto-imported modules via `importTree`.

## ethos

This repo values simplicity, readability, and maintainability above all else.
Every addition should be questioned: is this necessary? can it be simpler?

- **comments**: minimize them. only add when the code cannot be made clear
  through context and naming. lowercase, no trailing punctuation.
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

- `desktop` — amd + nvidia gaming/workstation (cachyos kernel, nixos-facter, plymouth, grub)
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

note: `-vm` packages are only for desktop, laptop, and server. wsl uses
nixos-wsl which is tested differently.

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

`nixpkgs` (unstable), `sops-nix`, `nixos-hardware`, `disko`, `nixos-facter`,
`nix-cachyos-kernel`, `nixos-wsl`, `treefmt-nix`, `nixarr`, `zen-browser`.

## agent tooling

these tools are available on hosts that import `cli` or `development`
(desktop, laptop, wsl). prefer them over slower alternatives:

### trimming output

pipe verbose commands through these to extract only what's needed:

- `jc` — convert any command output to json, then query with `jq`:
  `ps aux | jc --ps | jq '.[] | select(.state == "Z")'`
  `journalctl --output=json | jc --journalctl | jq '.[] | {message: .MESSAGE}'`
- `gron` — flatten json into grep-friendly lines so `rg` can search it:
  `cat data.json | gron | rg some.key`
- `choose` — field extraction by column index or name
- `rg` — regex search with `-C N` context, `--json` for structured output

### composing commands

- `fzf` — fuzzy filter any list, pipe output into next command
- `entr` — run commands when files change: `ls *.rs | entr cargo test`
- `sd` — find-and-replace with regex (way simpler than sed)
- `just` — write reusable command recipes in a justfile
- `watchexec` — watch directory + re-run on any change

### diagnosis

- `procs` — process viewer with tree/regex (never `ps aux | grep`)
- `btop` / `htop` — system resource monitors
- `dust` — disk usage (never `du -sh * | sort -h`)
- `bandwhich` — per-process network bandwidth
- `dogdns` — dns lookup (never `dig`/`nslookup`)
- `tealdeer` — quick command examples: `tldr <tool>`
- `nix-output-monitor` — compact nix build output (nom build)
- `nvd` — nix store version diff: `nvd diff /nix/store/old /nix/store/new`
- `nix-du` — nix store disk usage breakdown
- `hyperfine` — benchmark commands
- `difftastic` — syntax-aware structural diffs
- `grex` — generate regex from plain examples

### general purpose

- `fd` — file finding (never `find`)
- `bat` — file viewing with line numbers; `bat --plain` for scripts
- `eza` — dir listing + tree; `eza --tree` replaces `tree`
- `jq` / `yq` — json / yaml querying
- `delta` — better git diffs (already set as PAGER)
- `batgrep` / `batdiff` / `batman` / `batwatch` — bat wrappers
- `pv` — pipe progress monitor
