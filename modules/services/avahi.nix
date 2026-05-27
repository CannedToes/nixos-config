<<<<<<< HEAD
{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.avahi = {
    pkgs,
    lib,
    config,
    ...
  }: {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      # nssmdns6 = true;
||||||| (empty tree)
=======
{...}: {
  flake.nixosModules.avahi = {...}: {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
>>>>>>> 8a283fc (GINEMINANORMOUS REFACTOR)
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        userServices = true;
        workstation = true;
      };
    };
  };
}
