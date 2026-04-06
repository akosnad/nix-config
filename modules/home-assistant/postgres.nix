{
  flake.modules.nixos.home-assistant = {
    services.home-assistant.config = {
      recorder.db_url = "postgresql://@/hass";
    };
    services.postgresql = {
      ensureDatabases = [ "hass" ];
      ensureUsers = [
        {
          name = "hass";
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
