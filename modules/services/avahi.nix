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
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        # workstation = true;
      };
    };
  };
}
