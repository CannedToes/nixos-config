{...}: {
  flake.nixosModules.locale = {...}: {
    time.timeZone = "Africa/Johannesburg";
    i18n.defaultLocale = "en_ZA.UTF-8";
    services.xserver.xkb.layout = "us";
    console.keyMap = "us";
  };
}
