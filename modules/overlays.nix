{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem = { pkgs, ... }: {
    overlayAttrs = {
      # `pkgs` here is exactly the `prev` argument of an overlay,
      # so you can override any existing package directly.
      beets = pkgs.beets.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or []) ++ [
          pkgs.gobject-introspection
          pkgs.gst_all_1.gst-plugins-base
          pkgs.gst_all_1.gst-plugins-good
        ];
        propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or []) ++ [
          pkgs.python3Packages.pygobject3
          pkgs.python3Packages.gst-python
        ];
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [
          pkgs.wrapGAppsHook3
        ];
      });
      # You can add other package overrides or new packages here in exactly the same way.
    };
  };
}
