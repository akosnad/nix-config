{ config, ... }:
{
  config.flake.devices.l-desk-led = {
    info = "Tuya-based RGB LED strip (modded controller)";
    mac = "28:6D:CD:07:2A:6B";
    ip = "10.4.1.5";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  config.flake.modules.esphome."hosts/l-desk-led" = {
    imports = with config.flake.modules.esphome; [
      wifi-signal
    ];

    settings = {
      esphome.friendly_name = "Ákos asztali LED";
      esp32 = {
        board = "esp32-s3-devkitc-1";
        flash_size = "4MB";
        framework.type = "esp-idf";
      };

      output = [
        {
          platform = "ledc";
          id = "output_red";
          pin = "1";
        }
        {
          platform = "ledc";
          id = "output_green";
          pin = "2";
        }
        {
          platform = "ledc";
          id = "output_blue";
          pin = "3";
        }
      ];

      light = [{
        platform = "rgb";
        id = "light_rgb";
        name = "Fény";
        icon = "mdi:led-strip-variant";
        red = "output_red";
        green = "output_green";
        blue = "output_blue";
        restore_mode = "RESTORE_DEFAULT_OFF";
        gamma_correct = 1.4;
      }];

      remote_receiver.pin = {
        number = "6";
        inverted = true;
        mode = "INPUT_PULLUP";
        # dump = "all";
      };
    };
  };
}
