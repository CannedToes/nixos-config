{lib, ...}: {
  options.flake.homeModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = {};
    description = "home-manager modules exposed by this flake.";
  };

  imports = [
    ./common.nix
    ./desktop.nix
    ./laptop.nix
  ];
}
