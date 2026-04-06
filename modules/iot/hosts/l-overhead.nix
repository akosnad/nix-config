{ config, ... }:
{
  config.flake.devices.l-overhead = {
    info = "Athom 15W RGBCT Bulb";
    mac = "4C:EB:D6:DC:7F:4A";
    ip = "10.4.1.3";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  config.flake.modules.esphome."hosts/l-overhead" = {
    imports = with config.flake.modules.esphome; [
      athom-15w-bulb
    ];

    lamp-icon = "mdi:floor-lamp-torchiere";
    settings.esphome.friendly_name = "Ákos állólámpa";
  };
}
