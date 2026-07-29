{...}: {
  flake.nixosModules.networking = {...}: {
    networking.firewall.enable = true;
    networking.nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];

    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWTEHF9/6EHtpPUqWNUu3pIU7fZ588I3uUKw8SvaHx+ myles@wsl"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYm0nn+5HZIhGaLEB/bORe8kZAwUBytMFJKwD7MDFcZ root@server"
    ];
  };
}
