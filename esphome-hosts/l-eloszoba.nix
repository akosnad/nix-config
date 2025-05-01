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
    sensor = with (common.sensorPresets "Előszoba lámpa"); [
      wifi_signal
    ];
  };
}
