{...}: {
  flake.nixosModules.cli = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # -- da mothaload --
      busybox

      # -- archive/extraction --
      p7zip

      # -- filesystem --
      dosfstools
      ntfs3g

      # -- network --
      curl

      # -- process/system monitoring --
      htop
      iotop

      # -- disk --
      ncdu
    ];
  };
}
