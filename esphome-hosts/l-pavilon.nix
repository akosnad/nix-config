_:
{
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
    }];

    remote_receiver.pin = {
      number = "P14";
      inverted = true;
      mode = "INPUT_PULLUP";
      # dump = "all";
    };
  };
}
