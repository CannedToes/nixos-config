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
      promptInit = ''PS1="\[\e[38;5;135m\]\u\[\e[38;5;247;2m\]@\[\e[0;38;5;197m\]\h\[\e[38;5;75m\] \[\e[38;5;255m\]\w\[\e[0m\] \[\e[38;5;112m\]\$\[\e[0m\] "'';
    };

    environment.systemPackages = [pkgs.helix];

    environment.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };
  };
}
