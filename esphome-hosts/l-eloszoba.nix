{ common, ... }:
{
  settings = {
    esphome.friendly_name = "Előszoba lámpa";
    esp32 = {
      board = "wemos_d1_mini32";
      framework.type = "esp-idf";
    };

    output =
      let
        frequency = "19531Hz";
        max_power = 0.88;
        min_power = 0.01;
      in
      [
        {
          platform = "ledc";
          pin = "GPIO19";
          id = "output_warm";
          inherit frequency max_power min_power;
          zero_means_zero = true;
        }
        {
          platform = "ledc";
          pin = "GPIO23";
          id = "output_cold";
          inherit frequency max_power min_power;
          zero_means_zero = true;
        }
        {
          platform = "ledc";
          pin = "GPIO18";
          id = "output_nightlight";
          frequency = "19531Hz";
          max_power = 0.25;
          min_power = 0.02;
          zero_means_zero = true;
        }
      ];
    light = [
      {
        platform = "monochromatic";
        name = "Éjszakai fény";
        id = "night_light";
        icon = "mdi:weather-night";
        output = "output_nightlight";
        gamma_correct = 1.5;
        restore_mode = "RESTORE_DEFAULT_OFF";
        on_turn_on = [
          { "light.turn_off" = "ceiling_light"; }
          { "globals.set" = { id = "last_used_light"; value = "1"; }; }
        ];
      }
      {
        platform = "cwww";
        name = "Fő fény";
        id = "ceiling_light";
        icon = "mdi:light-recessed";
        cold_white = "output_cold";
        warm_white = "output_warm";
        cold_white_color_temperature = "6000K";
        warm_white_color_temperature = "2700K";
        constant_brightness = true;
        gamma_correct = 2.2;
        restore_mode = "RESTORE_DEFAULT_ON";
        on_turn_on = [
          { "light.turn_off" = "night_light"; }
          { "globals.set" = { id = "last_used_light"; value = "0"; }; }
        ];
      }
    ];
    sensor = with common.sensorPresets; [
      wifi_signal
    ];
    bluetooth_proxy = { };
    globals = [
      {
        id = "last_used_light";
        type = "int";
        restore_value = true;
        initial_value = "0";
      }
      {
        id = "colortemp_cycle";
        type = "int";
        restore_value = true;
        initial_value = "0";
      }
      {
        id = "colortemp_cycle_direction";
        type = "int";
        restore_value = true;
        initial_value = "0";
      }
    ];
  } // (common.yee-rc {
    mac_address = "F8:24:41:ED:0B:9D";
    on_press =
      let
        dimStepPercent = 10;
      in
      [
        {
          keycode = 0; # ON
          "then" = [{
            "if" = {
              condition.lambda = "return id(last_used_light) == 0;";
              "then" = [{ "light.turn_on" = "ceiling_light"; }];
              "else" = [{ "light.turn_on" = "night_light"; }];
            };
          }];
        }
        {
          keycode = 1; # OFF
          "then" = [
            { "light.turn_off" = "night_light"; }
            { "light.turn_off" = "ceiling_light"; }
          ];
        }
        {
          keycode = 2; # Sun
          "then" = [{
            "if" = {
              condition."light.is_on" = "ceiling_light";
              "then".lambda = /* cpp */ ''
                const int num_steps = 5;
                if(id(colortemp_cycle) == 0 && id(colortemp_cycle_direction) == 0) {
                  id(colortemp_cycle) = 1;
                  id(colortemp_cycle_direction) = 1;
                } else if(id(colortemp_cycle) == num_steps - 1 && id(colortemp_cycle_direction) == 1) {
                  id(colortemp_cycle) = num_steps - 2;
                  id(colortemp_cycle_direction) = 0;
                } else if(id(colortemp_cycle_direction) == 1) {
                  id(colortemp_cycle) += 1;
                } else {
                  id(colortemp_cycle) -= 1;
                }

                const int step_size = 5990 - 2700;
                float kelvin = (float(id(colortemp_cycle)) * float(step_size / num_steps)) + 2700.0;
                auto call = id(ceiling_light).turn_on();
                call.set_color_temperature(1000000.0 / kelvin);
                call.perform();
              '';
            };
          }];
        }
        {
          keycode = 3; # +
          "then" = [{
            "if" = {
              condition."light.is_on" = "ceiling_light";
              "then"."light.dim_relative" = {
                id = "ceiling_light";
                relative_brightness = "${toString dimStepPercent}%";
              };
              "else"."light.dim_relative" = {
                id = "night_light";
                relative_brightness = "${toString dimStepPercent}%";
              };
            };
          }];
        }
        {
          keycode = 4; # M
          "then" = [{
            "if" = {
              condition."light.is_on" = "ceiling_light";
              "then"."light.turn_on" = "night_light";
              "else"."light.turn_on" = "ceiling_light";
            };
          }];
        }
        {
          keycode = 5; # -
          "then" = [{
            "if" = {
              condition."light.is_on" = "ceiling_light";
              "then"."light.dim_relative" = {
                id = "ceiling_light";
                relative_brightness = "-${toString dimStepPercent}%";
              };
              "else"."light.dim_relative" = {
                id = "night_light";
                relative_brightness = "-${toString dimStepPercent}%";
              };
            };
          }];
        }
      ];
    on_long_press = [ ];
  });
}
