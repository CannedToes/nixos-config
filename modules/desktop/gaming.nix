{...}: {
  flake.nixosModules.gaming = {pkgs, ...}: {
    programs.steam = {
      enable = true;
      extraCompatPackages = with pkgs; [proton-ge-bin];
      protontricks.enable = true;
      gamescopeSession.enable = true;
    };

    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    programs.gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general.renice = 10;
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      mangohud
      # lutris
      # heroic
      # bottles
      wineWow64Packages.stable
      winetricks
      dxvk
      vkd3d-proton
    ];
  };
}
