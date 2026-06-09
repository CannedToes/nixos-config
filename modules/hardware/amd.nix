{...}: {
  flake.nixosModules.amd = {...}: {
    hardware.cpu.amd.updateMicrocode = true;
  };
}
