{inputs, ...}: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  systems = ["x86_64-linux"];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      programs.alejandra.enable = true;
    };
  };
}
