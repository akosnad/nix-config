{ config, ... }:
{
  services.home-assistant = {
    enable = true;
    openFirewall = false;
    extraComponents = [
      "default_config"
      "met"
      "esphome"
      "google_translate"
      "shopping_list"
      "radio_browser"
    ];
    config = {
      default_config = {};
      homeassistant = {
        name = "Gaia";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = "!secret elevation";
        unit_system = "metric";
        time_zone = "Europe/Budapest";
      };
      frontend = {
        themes = "!include_dir_merge_named themes";
      };
      http = {};
    };
  };

  sops.secrets.home-assistant-secrets = {
    owner = config.systemd.services.home-assistant.serviceConfig.User;
    sopsFile = ./secrets.yaml;
    path = "/var/lib/hass/secrets.yaml";
    restartUnits = [ "home-assistant.service" ];
  };
}
