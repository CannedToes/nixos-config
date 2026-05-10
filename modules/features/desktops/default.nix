{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.desktop = {
    pkgs,
    lib,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      feishin
      megacmd
      megasync
      mpv
    ];

    services.libinput.enable = true;
  };
}
