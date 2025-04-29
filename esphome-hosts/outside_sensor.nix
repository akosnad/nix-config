{
  settings = {
    esphome = {
      platform = "ESP8266";
      board = "d1_mini";
    };
    i2c = [{
      sda = "D3";
      scl = "D4";
      scan = "True";
    }];
    sensor = [
      {
        platform = "wifi_signal";
        name = "Outside Sensor Signal";
        update_interval = "10s";
      }
      {
        platform = "bh1750";
        name = "Outside Illuminance";
        address = 35;
        filters = [ "quantile" ];
        update_interval = "15s";
      }
      {
        platform = "bme280_i2c";
        temperature = {
          name = "Outside Temperature";
          oversampling = "16x";
          filters = [ "quantile" ];
        };
        pressure = {
          name = "Outside Pressure";
          accuracy_decimals = 3;
          filters = null;
        };
        humidity = {
          name = "Outside Humidity";
          filters = [ "quantile" ];
        };
        address = 118;
        iir_filter = "2x";
        update_interval = "60s";
      }
    ];
  };
}
