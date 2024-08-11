{ config, ... }:
{
  services.home-assistant.config.zone = "!include zones.yaml";

  sops.secrets."home-assistant-zones" = {
    owner = config.systemd.services.home-assistant.serviceConfig.User;
    sopsFile = ./secrets.yaml;
    path = "/var/lib/hass/zones.yaml";
    restartUnits = [ "home-assistant.service" ];
  };
}
