# TODO: module system similar to NixOS options
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
      update_interval = "5s";
    };
    bme280 = {
      platform = "bme280_i2c";
      temperature = {
        name = "${prefix} Temperature";
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
      iir_filter = "16x";
      update_interval = "5s";
    };
  };

  yee-rc = { mac_address, prefix }: {
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
      inherit mac_address;
      # Button  Keycode
      # on      0
      # off     1
      # sun     2
      # +       3
      # m       4
      # -       5
      last_button_pressed.name = "${prefix} Távirányító utolsó lenyomott gomb";
      on_press = [
        {
          keycode = 0;
          "then" = [{ "event.trigger" = { id = "remote_button_press"; event_type = "on_press"; }; }];
        }
        {
          keycode = 1;
          "then" = [{ "event.trigger" = { id = "remote_button_press"; event_type = "off_press"; }; }];
        }
        {
          keycode = 2;
          "then" = [{ "event.trigger" = { id = "remote_button_press"; event_type = "sun_press"; }; }];
        }
        {
          keycode = 3;
          "then" = [{ "event.trigger" = { id = "remote_button_press"; event_type = "plus_press"; }; }];
        }
        {
          keycode = 4;
          "then" = [{ "event.trigger" = { id = "remote_button_press"; event_type = "m_press"; }; }];
        }
        {
          keycode = 5;
          "then" = [{ "event.trigger" = { id = "remote_button_press"; event_type = "minus_press"; }; }];
        }
      ];
      on_long_press = [
        {
          keycode = 0;
          "then" = [{ "event.trigger" = { id = "remote_button_press"; event_type = "on_long_press"; }; }];
        }
        {
          keycode = 1;
          "then" = [{ "event.trigger" = { id = "remote_button_press"; event_type = "off_long_press"; }; }];
        }
        {
          keycode = 2;
          "then" = [{ "event.trigger" = { id = "remote_button_press"; event_type = "sun_long_press"; }; }];
        }
        {
          keycode = 3;
          "then" = [{ "event.trigger" = { id = "remote_button_press"; event_type = "plus_long_press"; }; }];
        }
        {
          keycode = 4;
          "then" = [{ "event.trigger" = { id = "remote_button_press"; event_type = "m_long_press"; }; }];
        }
        {
          keycode = 5;
          "then" = [{ "event.trigger" = { id = "remote_button_press"; event_type = "minus_long_press"; }; }];
        }
      ];
    };
    event = [{
      platform = "template";
      id = "remote_button_press";
      name = "${prefix} Távirányító gombnyomás";
      device_class = "button";
      icon = "mdi:remote";
      event_types = [
        "on_press"
        "on_long_press"
        "off_press"
        "off_long_press"
        "sun_press"
        "sun_long_press"
        "plus_press"
        "plus_long_press"
        "m_press"
        "m_long_press"
        "minus_press"
        "minus_long_press"
      ];
    }];
  };
}
