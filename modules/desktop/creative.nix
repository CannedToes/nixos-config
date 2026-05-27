{...}: {
  flake.nixosModules.creative = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      blender
      cudaPackages.cudatoolkit
      frei0r
      kdePackages.kdenlive
      kdePackages.qtimageformats
      ladspaPlugins
      libva-utils
      mediainfo
      vulkan-tools
    ];
  };
}
