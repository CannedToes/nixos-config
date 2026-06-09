{...}: {
  flake.nixosModules.movim = {...}: {
    services.movim = {
      enable = true;
      domain = "chat.myles.onl";

      database = {
        type = "postgresql";
        createLocally = true;
      };

      podConfig = {
        chatonly = true;
        description = "Myles XMPP chat";
        disableregistration = true;
        restrictsuggestions = true;
        xmppdomain = "myles.onl";
        xmppdescription = "Myles XMPP";
      };

      settings = {
        DAEMON_INTERFACE = "127.0.0.1";
      };

      nginx = {
        useACMEHost = "myles.onl";
        forceSSL = true;
      };
    };
  };
}
