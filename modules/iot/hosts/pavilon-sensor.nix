{ config, ... }:
{
  config.flake.devices.pavilon-sensor = {
    mac = "D8:13:2A:2E:E2:D4";
    ip = "10.4.2.6";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  config.flake.modules.esphome."hosts/pavilon-sensor" = {
    imports = with config.flake.modules.esphome; [
      wifi-signal
      bme280
    ];

    settings = {
      esphome.friendly_name = "Pavilon szenzor";
      esp32 = {
        board = "wemos_d1_mini32";
        framework.type = "esp-idf";
      };
      i2c = [{
        sda = "GPIO25";
        scl = "GPIO27";
        scan = true;
      }];
      esp32_ble_tracker.scan_parameters.active = false;
      bluetooth_proxy = { };
    };
  };
}
