{ config, ... }:
{
  config.flake.devices.gate-button = {
    mac = "E4:B3:23:F8:23:40";
    ip = "10.4.2.7";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  config.flake.modules.esphome."hosts/gate-button" = {
    imports = with config.flake.modules.esphome; [
      wifi-signal
    ];

    settings = {
      esphome.friendly_name = "Gate opener button";
      esp32 = {
        variant = "esp32s3";
        board = "esp32-s3-devkitc-1";
        flash_size = "4MB";
        framework.type = "esp-idf";
      };

      binary_sensor = [{
        platform = "gpio";
        pin = {
          number = "GPIO7";
          inverted = true;
          mode = { input = true; pullup = true; };
        };
        id = "button";
        name = "Button";
        filters = [{ delayed_on_off = "30ms"; }];
      }];

      output = [{
        platform = "ledc";
        pin = "GPIO10";
        id = "led_out";
      }];

      light = [{
        platform = "monochromatic";
        output = "led_out";
        name = "Button LED";
        id = "led";
        icon = "mdi:led-outline";
        effects = [
          { pulse = { name = "Fast pulse"; transition_length = "500ms"; update_interval = "500ms"; }; }
          { pulse = { name = "Slow pulse"; transition_length = "500ms"; update_interval = "2s"; }; }
        ];
      }];
    };
  };
}
