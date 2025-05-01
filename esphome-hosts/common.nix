{
  sensorPresets = prefix: {
    wifi_signal = {
      platform = "wifi_signal";
      name = "Signal";
      update_interval = "10s";
    };
    bh1750 = {
      platform = "bh1750";
      name = "${prefix} Illuminance";
      address = 35;
      filters = [ "quantile" ];
      update_interval = "15s";
    };
    bme280 = {
      platform = "bme280_i2c";
      temperature = {
        name = "${prefix} Temperature";
        oversampling = "16x";
        filters = [ "quantile" ];
      };
      pressure = {
        name = "${prefix} Pressure";
        accuracy_decimals = 3;
        filters = [ "quantile" ];
      };
      humidity = {
        name = "${prefix} Humidity";
        filters = [ "quantile" ];
      };
      address = 118;
      iir_filter = "2x";
      update_interval = "60s";
    };
  };
}
