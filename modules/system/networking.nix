{...}: {
  flake.nixosModules.networking = {...}: {
    networking.firewall.enable = true;
    networking.nameservers = [
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBVYD8n4BPgvp7G8gOmZ2o0DF9FnE2unjwhscUKHDAp myles@granite"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWTEHF9/6EHtpPUqWNUu3pIU7fZ588I3uUKw8SvaHx+ myles@wsl"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYm0nn+5HZIhGaLEB/bORe8kZAwUBytMFJKwD7MDFcZ root@server"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBqTiWPREJZ0wY6wIMW6kbkmK5uqnnG1jl2ga5CHzc9 myles@laptop"
    ];
  };
}
