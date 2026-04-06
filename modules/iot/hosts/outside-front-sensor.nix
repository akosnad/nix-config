{ config, ... }:
{
  config.flake.devices.outside-front-sensor = {
    mac = "98:CD:AC:26:10:8A";
    ip = "10.4.2.4";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  config.flake.modules.esphome."hosts/outside-front-sensor" = {
    imports = with config.flake.modules.esphome; [
      wifi-signal
      bme280
      bh1750
    ];

    settings = {
      esphome.friendly_name = "Kinti elöli szenzor";
      esp8266.board = "d1_mini";
      i2c = [{
        sda = "D3";
        scl = "D4";
        scan = true;
      }];
    };
  };
}
