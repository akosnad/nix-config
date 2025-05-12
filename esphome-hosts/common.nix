# TODO: module system similar to NixOS options
{
  sensorPresets = {
    wifi_signal = {
      platform = "wifi_signal";
      name = "Signal";
      update_interval = "10s";
    };
    bh1750 = {
      platform = "bh1750";
      name = "Illuminance";
      address = 35;
      filters = [ "quantile" ];
      update_interval = "5s";
    };
    bme280 = {
      platform = "bme280_i2c";
      temperature = {
        name = "Temperature";
        filters = [ "quantile" ];
      };
      pressure = {
        name = "Pressure";
        accuracy_decimals = 3;
        filters = [ "quantile" ];
      };
      humidity = {
        name = "Humidity";
        filters = [ "quantile" ];
      };
      address = 118;
      iir_filter = "16x";
      update_interval = "5s";
    };
  };

  yee-rc = { mac_address, on_press ? [ ], on_long_press ? [ ] }: {
    external_components = [{
      source = {
        type = "git";
        url = "https://github.com/syssi/esphome-yeelight-ceiling-light";
        ref = "3331ac9700819ec29a9fb8d42240153f894c31f8";
      };
      refresh = "never";
    }];
    esp32_ble_tracker.scan_parameters = {
      interval = "150ms";
      window = "150ms";
      duration = "1min";
      active = false;
    };
    xiaomi_ylyk01yl = {
      inherit mac_address on_press on_long_press;
      # Button  Keycode
      # on      0
      # off     1
      # sun     2
      # +       3
      # m       4
      # -       5
    };
  };
}
