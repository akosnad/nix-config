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
        name = "Indoor Sensor Signal";
        update_interval = "10s";
      }
      {
        platform = "bme280_i2c";
        temperature = {
          name = "Inside Temperature";
          filters = [ "quantile" ];
        };
        pressure = {
          name = "Inside Pressure";
          accuracy_decimals = 3;
          filters = null;
        };
        humidity = {
          name = "Inside Humidity";
          filters = [ "quantile" ];
        };
        address = 118;
        iir_filter = "16x";
        update_interval = "60s";
      }
    ];
  };
}
