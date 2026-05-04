{ self, inputs, ... }:
{
  flake.nixosModules.serverServices =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      imports = [
        self.nixosModules.hass
      ];
    };
}
