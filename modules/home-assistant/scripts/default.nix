{
  config.flake.modules.nixos.home-assistant = {
    services.home-assistant.config = {
      "script declarative" = [ ];
      "script ui" = "!include scripts.yaml";
    };
  };
}
