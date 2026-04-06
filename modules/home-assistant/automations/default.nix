{
  config.flake.modules.nixos.home-assistant = {
    services.home-assistant.config = {
      "automation declarative" = [ ];
      "automation ui" = "!include automations.yaml";
    };
  };
}
