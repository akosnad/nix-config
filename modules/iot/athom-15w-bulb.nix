{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  flakeConfig = config;
in
{
  config.flake.modules.esphome.athom-15w-bulb = { config, ... }: {
    imports = with flakeConfig.flake.modules.esphome; [
      wifi-signal
    ];

    options = {
      lamp-icon = mkOption {
        type = types.strMatching "^mdi:[a-z0-9-]+$";
      };
    };

    config = {
      settings = {
        esp8266 = {
          board = "esp8285";
          restore_from_flash = true;
        };
        preferences.flash_write_interval = "1min";

        button = [
          {
            platform = "restart";
            name = "Restart";
            entity_category = "config";
          }
          {
            platform = "factory_reset";
            name = "Factory Reset";
            id = "reset";
            entity_category = "config";
          }
          {
            platform = "safe_mode";
            name = "Safe Mode";
            internal = false;
            entity_category = "config";
          }
        ];

        output =
          let
            white_max_power = 0.6;
            max_power = 0.85;
          in
          [
            {
              platform = "esp8266_pwm";
              id = "red_output";
              pin = "GPIO4";
              min_power = 0.000499;
              inherit max_power;
              zero_means_zero = true;
            }
            {
              platform = "esp8266_pwm";
              id = "green_output";
              pin = "GPIO12";
              min_power = 0.000499;
              inherit max_power;
              zero_means_zero = true;
            }
            {
              platform = "esp8266_pwm";
              id = "blue_output";
              pin = "GPIO14";
              min_power = 0.000499;
              inherit max_power;
              zero_means_zero = true;
            }
            {
              platform = "esp8266_pwm";
              id = "white_output";
              pin = "GPIO5";
              min_power = 0.01;
              max_power = white_max_power;
              zero_means_zero = true;
            }
            {
              platform = "esp8266_pwm";
              id = "ct_output";
              inverted = true;
              pin = "GPIO13";
              min_power = 0.01;
              max_power = white_max_power;
              zero_means_zero = true;
            }
          ];

        light = [
          {
            platform = "rgbct";
            id = "rgbct_light";
            name = "Fény";
            icon = config.lamp-icon;
            restore_mode = "RESTORE_DEFAULT_ON";
            red = "red_output";
            green = "green_output";
            blue = "blue_output";
            white_brightness = "white_output";
            color_temperature = "ct_output";
            cold_white_color_temperature = "6000K";
            warm_white_color_temperature = "3000K";
            color_interlock = true;
          }
        ];
      };
    };
  };
}
