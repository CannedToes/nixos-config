{username, ...}: {
  flake.nixosModules.podman = {...}: {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
      dockerSocket.enable = true;
    };

    users.users.${username}.extraGroups = ["podman"];
  };
}
