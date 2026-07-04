{...}: {
  flake.nixosModules.networking = {...}: {
    networking.firewall.enable = true;
    networking.nameservers = [
      "1.1.1.1"
			"1.0.0.1"
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
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWTEHF9/6EHtpPUqWNUu3pIU7fZ588I3uUKw8SvaHx+ myles@wsl"
    ];
  };
}
