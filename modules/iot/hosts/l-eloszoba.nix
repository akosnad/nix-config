{ config, ... }:
{
  config.flake.devices.l-eloszoba = {
    info = "Mi LED Ceiling light (ceil5) (modded controller)";
    mac = "D8:13:2A:2E:DA:20";
    ip = "10.4.1.1";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  config.flake.modules.esphome."hosts/l-eloszoba" = {
    imports = with config.flake.modules.esphome; [
      xiaomi-ceiling-light
    ];

    settings = {
      esphome.friendly_name = "Előszoba lámpa";
      esp32 = {
        board = "wemos_d1_mini32";
        framework.type = "esp-idf";
      };

      output =
        let
          frequency = "1220Hz";
          max_power = 0.88;
          min_power = 0.06;
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
            inherit frequency;
            max_power = 0.25;
            min_power = 0.01;
            zero_means_zero = true;
          }
        ];
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

      xiaomi_ylyk01yl.mac_address = "F8:24:41:ED:0B:9D";
    };
  };
}
