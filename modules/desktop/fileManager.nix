{...}: {
  flake.nixosModules.fileManager = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      file-roller
      thunar
      yazi
    ];

    programs.thunar.enable = true;

    services = {
      gvfs.enable = true;
      tumbler.enable = true;
      udisks2.enable = true;
    };
  };
}
