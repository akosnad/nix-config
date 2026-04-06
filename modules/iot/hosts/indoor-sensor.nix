{ config, ... }:
{
  config.flake.devices.indoor-sensor = {
    mac = "8C:AA:B5:7C:FA:80";
    ip = "10.4.2.2";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  config.flake.modules.esphome."hosts/indoor-sensor" = {
    imports = with config.flake.modules.esphome; [
      wifi-signal
      bme280
      ens160
    ];

    settings = {
      esphome.friendly_name = "Előszoba szenzor";
      esp8266.board = "d1_mini";
      i2c = [{
        sda = "D3";
        scl = "D4";
        scan = "True";
      }];
    };
  };
}
