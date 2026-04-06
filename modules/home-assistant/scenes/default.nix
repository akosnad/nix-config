{
  config.flake.modules.nixos.home-assistant = {
    services.home-assistant.config = {
      "scene declarative" = [ ];
      "scene ui" = "!include scenes.yaml";
    };
  };
}
