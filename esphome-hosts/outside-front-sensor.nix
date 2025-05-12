{ common, ... }:
{
  settings = {
    esphome.friendly_name = "Kinti elöli szenzor";
    esp8266.board = "d1_mini";
    i2c = [{
      sda = "D3";
      scl = "D4";
      scan = true;
    }];
    sensor = with common.sensorPresets; [
      wifi_signal
      bh1750
      bme280
    ];
  };
}
