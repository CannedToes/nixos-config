{...}: {
  flake.nixosModules.cli = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      busybox
      p7zip
      dosfstools
      ntfs3g
      curl
      htop
      iotop
      ncdu
    ];
  };
}
