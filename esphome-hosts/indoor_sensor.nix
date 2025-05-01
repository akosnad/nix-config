{ common, ... }:
{
  settings = {
    esp8266.board = "d1_mini";
    i2c = [{
      sda = "D3";
      scl = "D4";
      scan = "True";
    }];
    sensor = with (common.sensorPresets "Inside"); [
      wifi_signal
      bme280
    ];
  };
}
