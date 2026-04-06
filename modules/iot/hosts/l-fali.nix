{ config, ... }:
{
  config.flake.devices.l-fali = {
    info = "Athom 15W RGBCT Bulb";
    mac = "D4:8C:49:0E:A0:78";
    ip = "10.4.1.6";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  config.flake.modules.esphome."hosts/l-fali" = {
    imports = with config.flake.modules.esphome; [
      athom-15w-bulb
    ];

    lamp-icon = "mdi:ceiling-light";
    settings.esphome.friendly_name = "Nagyszoba fali lámpa";
  };
}
