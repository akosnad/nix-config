{ config, ... }:
{
  config.flake.devices.l-desk-led = {
    info = "LSC Smart Connect Ledstrip RGBIC + CCTIC (custom firmware)";
    mac = "38:2C:E5:D2:AF:B2";
    ip = "10.4.1.5";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  config.flake.modules.esphome."hosts/l-desk-led" = {
    imports = with config.flake.modules.esphome; [
      wifi
    ];

    hostPlatform = "bk72xx";
    settings = {
      esphome.friendly_name = "Ákos asztali LED";
      bk72xx.board = "generic-bk7231n-qfn32-tuya";

      power_supply = [{
        id = "led_power";
        pin = "P8";
      }];

      e131 = { };

      light =
        let
          num_leds = 50;
          id = "ledstrip_internal";
        in
        [
          {
            platform = "beken_spi_led_strip";
            rgb_order = "BRG";
            pin = "P16";
            chipset = "SM16703";
            power_supply = "led_power";
            inherit num_leds id;
            name = "None";
            internal = true;
            restore_mode = "RESTORE_DEFAULT_OFF";
            gamma_correct = 1.0;
          }
          {
            platform = "partition";
            id = "light_rgb";
            name = "RGB";
            segments = map (x: { inherit id; from = x; to = x; }) (builtins.genList (x: x * 2) (num_leds / 2));
            restore_mode = "RESTORE_DEFAULT_OFF";
            gamma_correct = 1.0;
            effects = [
              { addressable_rainbow = { }; }
              { addressable_color_wipe = { }; }
              { addressable_scan = { }; }
              { addressable_twinkle = { }; }
              { addressable_random_twinkle = { }; }
              { addressable_fireworks = { }; }
              { addressable_flicker = { }; }
              { e131.universe = 1; }
            ];
          }
          {
            platform = "partition";
            id = "light_cct";
            name = "CCT";
            segments = map (x: { inherit id; from = x; to = x; }) (builtins.genList (x: x * 2 + 1) (num_leds / 2));
            restore_mode = "RESTORE_DEFAULT_ON";
            gamma_correct = 1.0;
          }
        ];
    };
  };
}
