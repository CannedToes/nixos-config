{inputs, ...}: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = _: {
    treefmt.programs = {
      deno.enable = true;
      nixfmt.enable = true;
    };
  };
}
