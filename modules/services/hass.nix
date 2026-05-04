{ self, inputs, ... }:
{
  flake.nixosModules.hass =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      services.home-assistant = {
        enable = true;
        openFirewall = true;
        extraPackages = python3Packages: with python3Packages; [ psycopg2 ];
        config = {
          homeassistant.name = "Glanville Home";
          homeassistant.temperature_unit = "C";
          homeassistant.unit_system = "metric";
        };
      };
    };
}
