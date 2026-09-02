{ ... }: {
  flake.nixosModules.plasma = {...}: {
    services.desktopManager.plasma6.enable = true;

    # Default display manager for Plasma
    services.displayManager.plasma-login-manager.enable = true;

    # Optionally enable xserver
    # xserver.enable = true;
  };
}
