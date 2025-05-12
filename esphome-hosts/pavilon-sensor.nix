{ common, ... }:
{
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
    sensor = with common.sensorPresets; [
      wifi_signal
      bme280
    ];
    esp32_ble_tracker.scan_parameters.active = false;
    bluetooth_proxy = { };
  };
}
