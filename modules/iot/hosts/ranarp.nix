{ config, ... }:
{
  config.flake.devices.ranarp = {
    info = "Athom 15W RGBCT Bulb";
    mac = "D4:8C:49:0E:8A:5F";
    ip = "10.4.1.7";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  config.flake.modules.esphome."hosts/ranarp" = {
    imports = with config.flake.modules.esphome; [
      athom-15w-bulb
    ];

    lamp-icon = "mdi:floor-lamp";
    settings.esphome.friendly_name = "Ranarp";
  };
}
