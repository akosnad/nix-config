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
        name = "Outside Front Sensor Signal";
        update_interval = "10s";
      }
      {
        platform = "bh1750";
        name = "Outside Front Illuminance";
        address = 35;
        filters = [ "quantile" ];
        update_interval = "15s";
      }
      {
        platform = "bme280_i2c";
        temperature = {
          name = "Outside Front Temperature";
          oversampling = "16x";
          filters = [ "quantile" ];
        };
        pressure = {
          name = "Outside Front Pressure";
          accuracy_decimals = 3;
          filters = null;
        };
        humidity = {
          name = "Outside Front Humidity";
          filters = [ "quantile" ];
        };
        address = 118;
        iir_filter = "2x";
        update_interval = "60s";
      }
    ];
  };
}
