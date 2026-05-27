{...}: {
  flake.nixosModules.cli = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # -- archive/extraction --
      p7zip
      unzip

      # -- filesystem --
      dosfstools
      ntfs3g

      # -- network --
      curl
      wget

      # -- process/system monitoring --
      htop
      iotop

      # -- disk --
      ncdu
    ];
  };
}
