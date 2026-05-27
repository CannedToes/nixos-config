# -- AMD CPU microcode --
# The actual nixos-hardware modules are imported directly in each host's
# config (common-cpu-amd, common-cpu-amd-pstate) because not every host
# has an AMD CPU. This module exists for any additional AMD-specific tweaks.
{...}: {
  flake.nixosModules.amd = {...}: {
    hardware.cpu.amd.updateMicrocode = true;
  };
}
