{ config, ... }:
{
  config.flake.devices.l-bokor-led = {
    mac = "FC:E8:C0:E1:0A:3C";
    ip = "10.4.1.10";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  config.flake.modules.esphome."hosts/l-bokor-led" = {
    imports = with config.flake.modules.esphome; [
      wifi-signal
    ];

    settings = {
      esphome.friendly_name = "Előszoba bokor";
      esp32 = {
        board = "lolin32";
        framework.type = "esp-idf";
      };

      output = [{
        platform = "ledc";
        id = "led_out";
        pin = 27;
      }];

      e131 = { };

      light = [
        {
          platform = "partition";
          id = "led";
          name = "LED";
          icon = "mdi:led-strip-variant";
          restore_mode = "RESTORE_DEFAULT_ON";
          segments = [{ single_light_id = "led_internal"; }];
          effects = [
            { e131 = { universe = 2; channels = "MONO"; }; }
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
                };
                update_interval = "1.5s";
              };
            }
          ];
        }
        {
          platform = "monochromatic";
          id = "led_internal";
          output = "led_out";
          internal = true;
        }
      ];
    };
  };
}
