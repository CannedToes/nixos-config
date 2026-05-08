# stolen from jakkunight on github (github.com/jakkunight/nitro-setup)
{
  inputs,
  withSystem,
  ...
}: {
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      # Put your overlays here:
      overlays = [];
      config = {
        allowUnfree = true;
      };
    };
  };
  flake.modules.nixos.nixpkgs = {
    imports = [
      inputs.nixpkgs.nixosModules.readOnlyPkgs
      (
        {config, ...}: {
          # Use the configured pkgs from perSystem
          nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform.system (
            {pkgs, ...}:
            # perSystem module arguments
              pkgs
          );
        }
      )
    ];
  };
}
