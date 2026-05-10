{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.systemHome = {
    pkgs,
    lib,
    config,
    ...
  }: {
    imports = [
      inputs.home-manager.nixosModules.default
    ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPkgs = true;
      backupFileExtension = "bak";
    };
  };
}
