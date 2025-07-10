{ common, ... }:
{
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
    }];

    remote_receiver.pin = {
      number = "6";
      inverted = true;
      mode = "INPUT_PULLUP";
      # dump = "all";
    };

    sensor = with common.sensorPresets; [
      wifi_signal
    ];
  };
}
