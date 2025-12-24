{ common, ... }:
{
  settings = {
    esphome.friendly_name = "Előszoba bokor";
    esp32 = {
      board = "lolin32";
      framework.type = "esp-idf";
    };

    sensor = with common.sensorPresets; [
      wifi_signal
    ];

    output = [{
      platform = "ledc";
      id = "led_out";
      pin = 27;
    }];

    light = [{
      platform = "monochromatic";
      id = "led";
      name = "LED";
      output = "led_out";
      icon = "mdi:led-strip-variant";
      restore_mode = "RESTORE_DEFAULT_ON";
      effects = [
        { pulse = { }; }
        {
          pulse = {
            name = "Fase Pulse";
            transition_length = "0.5s";
            update_interval = "0.5s";
            min_brightness = "0%";
            max_brightness = "100%";
          };

        }
        {
          pulse = {
            name = "Slow Pulse";
            transition_length = "500ms";
            update_interval = "2s";
          };
        }
        {
          pulse = {
            name = "Asymmetrical Pulse";
            transition_length = {
              on_length = "1s";
              off_length = "500ms";
              update_interval = "1.5s";
            };
          };
        }
      ];
    }];
  };

}
