{...}: {
  flake.nixosModules.networking = {...}: {
    networking.firewall.enable = true;
    services.resolved = {
      enable = true;
      settings.Resolve.FallbackDns = [
        "8.8.8.8#dns.quad9.net"
        "1.1.1.1#cloudflare-dns.com"
      ];
    };
    networking.nameservers = [
      "8.8.8.8"
      "1.1.1.1"
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFmotcueJgrko7lBYUAYKilC8Z99T497yUkl9wgk+ayy myles@laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIU1WdfeFe320nwVimkgjb+b7hDS6NL8Tvx8BdwuTYNn myles@wsl"
    ];
  };
}
