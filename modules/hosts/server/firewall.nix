{ inputs, self, ... }: {
  flake.nixosModules.serverFirewall = { lib, pkgs, ... }: {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
      };
    };
    networking.nftables.enable = true;
    networking.firewall = {
      enable = true;
      allowedUDPPorts = [ 5353 ]; # mdns
    };
  };
}
