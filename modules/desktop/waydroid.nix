{...}: {
  flake.nixosModules.waydroid = {pkgs, ...}: {
    virtualisation.waydroid.enable = true;
    virtualisation.waydroid.package = pkgs.waydroid-nftables;

    environment.systemPackages = with pkgs; [
      wl-clipboard
      waydroid-helper
    ];

    systemd = {
      packages = [pkgs.waydroid-helper];
      services.waydroid-mount.wantedBy = ["multi-user.target"];
    };

    services.geoclue2.enable = true;
  };
}
