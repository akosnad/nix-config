{ common, ... }:
{
  settings = {
    esp32.board = "wemos_d1_mini32";
    i2c = [{
      sda = "GPIO25";
      scl = "GPIO27";
      scan = true;
    }];
    sensor = with (common.sensorPresets "Pavilon"); [
      wifi_signal
      bme280
    ];
  };
}
