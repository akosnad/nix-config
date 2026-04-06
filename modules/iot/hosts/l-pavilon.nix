{
  config.flake.devices.l-pavilon = {
    info = "Tuya-based RGB LED strip (custom firmware)";
    mac = "D4:A6:51:91:0D:9E";
    ip = "10.4.1.9";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  config.flake.modules.esphome."hosts/l-pavilon" = {
    settings = {
      esphome.friendly_name = "Pavilon LED";
      bk72xx.board = "generic-bk7231t-qfn32-tuya";

      output =
        let
          max_power = 0.88;
        in
        [
          {
            platform = "libretiny_pwm";
            id = "output_red";
            pin = "P7";
            inherit max_power;
          }
          {
            platform = "libretiny_pwm";
            id = "output_green";
            pin = "P8";
            inherit max_power;
          }
          {
            platform = "libretiny_pwm";
            id = "output_blue";
            pin = "P6";
            inherit max_power;
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
        number = "P14";
        inverted = true;
        mode = "INPUT_PULLUP";
        # dump = "all";
      };
    };
  };
}
