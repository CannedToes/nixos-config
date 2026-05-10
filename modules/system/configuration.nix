{
  self,
  inputs,
  ...
}: {
  # these are general settings that you want applied to every host
  flake.nixosModules.systemConfiguration = {
    pkgs,
    lib,
    config,
    ...
  }: {
    nixpkgs.config.allowUnfree = true;
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      download-buffer-size = 524288000; # 500 MiB
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    networking.firewall.enable = true;

    services.openssh = {
      enable = true;
      openFirewall = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    users.users.root = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBqTiWPREJZ0wY6wIMW6kbkmK5uqnnG1jl2ga5CHzc9 myles@laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIU1WdfeFe320nwVimkgjb+b7hDS6NL8Tvx8BdwuTYNn myles@wsl"
      ];
    };

    time.timeZone = "Africa/Johannesburg";
    i18n.defaultLocale = "en_ZA.UTF-8";

    system.stateVersion = "26.05";
  };
}
