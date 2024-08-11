{
  services.home-assistant.config = {
    "automation declarative" = [{
      id = "create_backup";
      alias = "Create backup";
      trigger = {
        platform = "time";
        at = "04:00:00";
      };
      action = {
        service = "backup.create";
        data = {};
        metadata  = {};
      };
    }];
    "automation ui" = "!include automations.yaml";
  };
}
