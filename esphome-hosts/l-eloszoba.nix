{ common, ... }:
{
  settings = {
    esphome.friendly_name = "Előszoba lámpa";
    esp32.board = "wemos_d1_mini32";

    output =
      let
        frequency = "19531Hz";
        max_power = 0.88;
      in
      [
        {
          platform = "ledc";
          pin = "GPIO19";
          id = "output_warm";
          inherit frequency max_power;
        }
        {
          platform = "ledc";
          pin = "GPIO23";
          id = "output_cold";
          inherit frequency max_power;
        }
        {
          platform = "ledc";
          pin = "GPIO18";
          id = "output_nightlight";
          inherit frequency max_power;
        }
      ];
    light = [
      {
        platform = "monochromatic";
        name = "Éjszakai fény";
        id = "night_light";
        icon = "mdi:weather-night";
        output = "output_nightlight";
        gamma_correct = 0;
        restore_mode = "RESTORE_DEFAULT_OFF";
        on_turn_on = [{ "light.turn_off" = "ceiling_light"; }];
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
        gamma_correct = 0;
        restore_mode = "RESTORE_DEFAULT_ON";
        on_turn_on = [{ "light.turn_off" = "night_light"; }];
        effects = [
          { random = { }; }
          { pulse = { }; }
          { strobe = { }; }
          { flicker = { }; }
        ];
      }
    ];
    number = [{
      platform = "template";
      id = "pwm_freq_input";
      min_value = 0;
      max_value = 999999;
      step = 1;
      name = "PWM frekvencia";
      entity_category = "diagnostic";
      unit_of_measurement = "Hz";
      mode = "box";
      icon = "mdi:square-wave";
      optimistic = true;
      on_value."then" = [
        { "output.ledc.set_frequency" = { id = "output_warm"; frequency = ''!lambda "return x;"''; }; }
        { "output.ledc.set_frequency" = { id = "output_cold"; frequency = ''!lambda "return x;"''; }; }
      ];
    }];
    sensor = with (common.sensorPresets "Előszoba lámpa"); [
      wifi_signal
    ];
  };
}
