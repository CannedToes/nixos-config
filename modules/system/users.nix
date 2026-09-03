{...}: {
  flake.nixosModules.users = {pkgs, ...}: {
    users.users.myles = {
      isNormalUser = true;
      initialPassword = "changeme";
      description = "Myles Glanville";
      extraGroups = ["networkmanager" "wheel" "audio" "video" "media" "dialout"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBqTiWPREJZ0wY6wIMW6kbkmK5uqnnG1jl2ga5CHzc9 myles@laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWTEHF9/6EHtpPUqWNUu3pIU7fZ588I3uUKw8SvaHx+ myles@wsl"
      ];
    };

    programs.bash = {
      enable = true;
    };

    environment.systemPackages = [ pkgs.helix ];

    environment.sessionVariables = {
      EDITOR = "hx";
      PAGER = "delta";
      VISUAL = "hx";
    };
  };
}
