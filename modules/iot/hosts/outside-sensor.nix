{ config, ... }:
{
  config.flake.devices.outside-sensor = {
    mac = "8C:AA:B5:7A:AD:A6";
    ip = "10.4.2.3";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  config.flake.modules.esphome."hosts/outside-sensor" = {
    imports = with config.flake.modules.esphome; [
      wifi-signal
      bme280
      bh1750
    ];

    settings = {
      esphome.friendly_name = "Kinti hátsó szenzor";
      esp8266.board = "d1_mini";
      i2c = [{
        sda = "D3";
        scl = "D4";
        scan = true;
      }];
    };
  };
}
