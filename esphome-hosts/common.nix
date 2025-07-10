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

  athom-15w-bulb = { icon }: {
    esp8266 = {
      board = "esp8285";
      restore_from_flash = true;
    };
    preferences.flash_write_interval = "1min";

    sensor = [{
      platform = "wifi_signal";
      name = "Signal";
      update_interval = "10s";
    }];
    button = [
      {
        platform = "restart";
        name = "Restart";
        entity_category = "config";
      }
      {
        platform = "factory_reset";
        name = "Factory Reset";
        id = "reset";
        entity_category = "config";
      }
      {
        platform = "safe_mode";
        name = "Safe Mode";
        internal = false;
        entity_category = "config";
      }
    ];

    output =
      let
        max_power = 0.85;
      in
      [
        {
          platform = "esp8266_pwm";
          id = "red_output";
          pin = "GPIO4";
          min_power = 0.000499;
          inherit max_power;
          zero_means_zero = true;
        }
        {
          platform = "esp8266_pwm";
          id = "green_output";
          pin = "GPIO12";
          min_power = 0.000499;
          inherit max_power;
          zero_means_zero = true;
        }
        {
          platform = "esp8266_pwm";
          id = "blue_output";
          pin = "GPIO14";
          min_power = 0.000499;
          inherit max_power;
          zero_means_zero = true;
        }
        {
          platform = "esp8266_pwm";
          id = "white_output";
          pin = "GPIO5";
          min_power = 0.01;
          inherit max_power;
          zero_means_zero = true;
        }
        {
          platform = "esp8266_pwm";
          id = "ct_output";
          inverted = true;
          pin = "GPIO13";
          min_power = 0.01;
          inherit max_power;
          zero_means_zero = true;
        }
      ];

    light = [{
      platform = "rgbct";
      id = "rgbct_light";
      name = "Fény";
      inherit icon;
      restore_mode = "RESTORE_DEFAULT_ON";
      red = "red_output";
      green = "green_output";
      blue = "blue_output";
      white_brightness = "white_output";
      color_temperature = "ct_output";
      cold_white_color_temperature = "6000K";
      warm_white_color_temperature = "3000K";
      color_interlock = true;
    }];
  };
}
