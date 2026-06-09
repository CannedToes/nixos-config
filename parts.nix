{inputs, ...}: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  systems = ["x86_64-linux"];

  _module.args.username = "myles";

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      programs.alejandra.enable = true;
    };
  };
}
