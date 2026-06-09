{...}: {
  flake.nixosModules.session = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      blueman
      networkmanagerapplet
      pavucontrol
      polkit_gnome
      swaybg
      wf-recorder
      xdg-utils
    ];
  };
}
