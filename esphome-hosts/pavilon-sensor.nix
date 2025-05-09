{ common, ... }:
{
  settings = {
    esp32.board = "wemos_d1_mini32";
    i2c = [{
      sda = "GPIO2";
      scl = "GPIO4";
      scan = true;
    }];
    sensor = with (common.sensorPresets "Pavilon"); [
      wifi_signal
      bme280
    ];
  };
}
