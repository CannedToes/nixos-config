{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.serverServices = {
    lib,
    pkgs,
    config,
    ...
  }: {
    imports = [
      self.nixosModules.avahi
      self.nixosModules.ddclient
      self.nixosModules.hass
      self.nixosModules.nginx
      self.nixosModules.ntfy
      self.nixosModules.vaultwarden
    ];
  };
}
