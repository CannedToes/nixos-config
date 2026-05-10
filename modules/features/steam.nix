{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.steam = {
    pkgs,
    lib,
    config,
    ...
  }: {
    programs.steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };
  };
}
