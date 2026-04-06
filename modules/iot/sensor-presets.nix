{
  config.flake.modules.esphome = {
    wifi-signal = {
      settings.sensor = [{
        platform = "wifi_signal";
        name = "Signal";
        update_interval = "10s";
      }];
    };
    bh1750 = {
      settings.sensor = [{
        platform = "bh1750";
        name = "Illuminance";
        address = 35;
        filters = [ "quantile" ];
        update_interval = "5s";
      }];
    };
    bme280 = {
      settings.sensor = [{
        platform = "bme280_i2c";
        temperature = {
          name = "Temperature";
          id = "temperature";
          filters = [ "quantile" ];
        };
        pressure = {
          name = "Pressure";
          id = "pressure";
          accuracy_decimals = 3;
          filters = [ "quantile" ];
        };
        humidity = {
          name = "Humidity";
          id = "humidity";
          filters = [ "quantile" ];
        };
        address = 118;
        iir_filter = "16x";
        update_interval = "5s";
      }];
    };
    aht20 = {
      settings.sensor = [{
        platform = "aht10";
        variant = "AHT20";
        update_interval = "5s";
        temperature = {
          name = "Temperature";
          id = "temperature";
          filters = [ "quantile" ];
        };
        humidity = {
          name = "Humidity";
          id = "humidity";
          filters = [ "quantile" ];
        };
      }];
    };
    ens160 = {
      settings.sensor = [{
        platform = "ens160_i2c";
        update_interval = "30s";
        eco2 = {
          name = "eCO2";
          id = "eco2";
        };
        tvoc = {
          name = "Total Volatile Organic Compounds";
          id = "tvoc";
        };
        aqi = {
          name = "Air Quality Index";
          id = "aqi";
        };
        compensation = {
          temperature = "temperature";
          humidity = "humidity";
        };
      }];
    };
  };
}
