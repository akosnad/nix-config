{ common, ... }:
{
  settings = {
    esphome.friendly_name = "Ákos asztali lámpa";
    esp8266.board = "esp8285";
    binary_sensor = [{
      platform = "gpio";
      id = "button";
      name = "l-desk Button";
      pin = { number = "GPIO2"; inverted = true; };
      on_click = { "then" = [{ "light.toggle" = "light1"; }]; };
    }];
    light = [{
      platform = "cwww";
      id = "light1";
      icon = "mdi:desk-lamp";
      default_transition_length = "0s";
      constant_brightness = true;
      name = "l-desk Light";
      cold_white = "output_cold";
      warm_white = "output_warm";
      cold_white_color_temperature = "6500K";
      warm_white_color_temperature = "2700K";
      gamma_correct = 0;
    }];
    output = [
      {
        platform = "esp8266_pwm";
        pin = "GPIO4";
        id = "output_cold";
      }
      {
        platform = "esp8266_pwm";
        pin = "GPIO5";
        id = "output_warm";
      }
    ];
    sensor = with common.sensorPresets; [
      wifi_signal
      {
        platform = "rotary_encoder";
        id = "rotation";
        pin_a = "GPIO13";
        pin_b = "GPIO12";
        resolution = 2;
        on_value."then" = [
          {
            "if" = {
              # check if button is pressed while rotating
              condition = { lambda = "return id(button).state;"; };
              "then" = [{
                # if button is pressed, change CW/WW
                lambda = ''
                  auto min_temp = id(light1).get_traits().get_min_mireds();
                  auto max_temp = id(light1).get_traits().get_max_mireds();
                  auto cur_temp = id(light1).current_values.get_color_temperature();
                  auto new_temp = max(min_temp, min(max_temp, cur_temp + (x * 10)));
                  auto call = id(light1).turn_on();
                  call.set_color_temperature(new_temp);
                  call.perform();'';
              }];
              # if button is not pressed, change brightness
              "else" = [{
                "light.dim_relative" = {
                  id = "light1";
                  relative_brightness = ''!lambda "return x / 25.0;"'';
                };
              }];
            };
          }
          {
            # reset rotation to 0
            "sensor.rotary_encoder.set_value" = { id = "rotation"; value = 0; };
          }
        ];
      }
    ];
  };
}
