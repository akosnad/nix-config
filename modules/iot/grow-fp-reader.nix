{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  config.flake.modules.esphome.grow-fp-reader = { config, ... }:
    let
      cfg = config.fp-reader;
    in
    {
      options.fp-reader = {
        id = mkOption {
          type = types.str;
          default = "fp";
        };
        sensing_pin = mkOption {
          type = types.either types.str types.int;
        };
        tx_pin = mkOption {
          type = types.either types.str types.int;
        };
        rx_pin = mkOption {
          type = types.either types.str types.int;
        };
      };
      config.settings = {
        uart = {
          inherit (cfg) tx_pin rx_pin;
          baud_rate = 57600;
        };
        fingerprint_grow = {
          inherit (cfg) id sensing_pin;

          on_finger_scan_start = [{
            "fingerprint_grow.aura_led_control" = {
              color = "BLUE";
              count = 0;
              speed = 0;
              state = "ALWAYS_ON";
            };
          }];
          on_enrollment_done = [{
            "fingerprint_grow.aura_led_control" = {
              color = "GREEN";
              count = 2;
              speed = 100;
              state = "BREATHING";
            };
          }];
          on_enrollment_failed = [{
            "fingerprint_grow.aura_led_control" = {
              color = "RED";
              count = 4;
              speed = 25;
              state = "FLASHING";
            };
          }];
          on_enrollment_scan = [
            {
              "fingerprint_grow.aura_led_control" = {
                color = "BLUE";
                count = 2;
                speed = 25;
                state = "FLASHING";
              };
            }
            {
              "fingerprint_grow.aura_led_control" = {
                color = "PURPLE";
                count = 0;
                speed = 0;
                state = "ALWAYS_ON";
              };
            }
          ];
          on_finger_scan_matched = [{
            "fingerprint_grow.aura_led_control" = {
              color = "GREEN";
              count = 1;
              speed = 200;
              state = "BREATHING";
            };
          }];
          on_finger_scan_misplaced = [{
            "fingerprint_grow.aura_led_control" = {
              color = "RED";
              count = 2;
              speed = 25;
              state = "FLASHING";
            };
          }];
          on_finger_scan_unmatched = [{
            "fingerprint_grow.aura_led_control" = {
              color = "RED";
              count = 2;
              speed = 25;
              state = "FLASHING";
            };
          }];
        };

        button = [{
          platform = "template";
          name = "Enroll finger";
          on_press."then" = [
            { "fingerprint_grow.enroll" = { finger_id = 0; }; }
            {
              "fingerprint_grow.aura_led_control" = {
                state = "ALWAYS_ON";
                speed = 0;
                color = "PURPLE";
                count = 0;
              };
            }
          ];
        }];
      };
    };
}
