{ config, ... }:
{
  config.flake.devices = {
    arwen = {
      info = "Yeelight Arwen 550C (ceilc) (custom firmware)";
      mac = "B4:60:ED:0F:CB:0D";
      ip = "10.4.1.2";
      blockInternetAccess = true;
      connectionMedium = "wifi";
    };
  };

  config.flake.modules.esphome."hosts/arwen" = {
    imports = with config.flake.modules.esphome; [
      xiaomi-ceiling-light
    ];

    settings = {
      esphome.friendly_name = "Arwen";
      esp32 = {
        variant = "esp32";
        framework = {
          type = "esp-idf";
          sdkconfig_options = {
            CONFIG_FREERTOS_UNICORE = "y";
          };
          advanced = {
            ignore_efuse_mac_crc = true;
            ignore_efuse_custom_mac = true;
          };
        };
      };

      sensor = [{
        platform = "adc";
        pin = "GPIO35";
        name = "Power supply";
        attenuation = "12db";
        entity_category = "diagnostic";
      }];

      output = [
        {
          platform = "ledc";
          pin = "GPIO19";
          id = "output_warm";
          power_supply = "power";
          max_power = 0.5;
        }
        {
          platform = "ledc";
          pin = "GPIO21";
          id = "output_cold";
          power_supply = "power";
          max_power = 0.96;
        }

        {
          platform = "ledc";
          pin = "GPIO23";
          id = "output_nightlight";
          power_supply = "power";
        }

        {
          platform = "ledc";
          pin = "GPIO33";
          id = "output_red";
          power_supply = "power";
        }
        {
          platform = "ledc";
          pin = "GPIO26";
          id = "output_green";
          power_supply = "power";
        }
        {
          platform = "ledc";
          pin = "GPIO27";
          id = "output_blue";
          power_supply = "power";
        }
      ];

      power_supply = [{
        id = "power";
        pin = "GPIO22";
        enable_time = "0s";
        keep_on_time = "0s";
      }];

      light = [
        {
          platform = "rgb";
          name = "Hangulatvilágítás";
          red = "output_red";
          green = "output_green";
          blue = "output_blue";
          icon = "mdi:wall-sconce-round-variant";
          restore_mode = "RESTORE_DEFAULT_OFF";
        }
      ];

      xiaomi_ylyk01yl.mac_address = "F8:24:41:ED:0A:B0";
    };
  };
}
