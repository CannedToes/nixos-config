# -- Firefox web browser --
{...}: {
  flake.nixosModules.firefox = {...}: {
    programs.firefox.enable = true;
  };
}
