{ config, ... }:
let
  flake.devices.alarm = {
    info = "ESP32-based home alarm system";
    mac = "02:00:00:FC:18:01";
    ip = "10.4.0.1";
    blockInternetAccess = true;
  };

  pirSensors = [
    { id = "eloszoba_mozgas"; name = "Előszoba mozgás"; pin = 16; trigger_mode = "delayed"; }
    { id = "nagyszoba_mozgas"; name = "Nagyszoba mozgás"; pin = 4; }
    { id = "haloszoba_mozgas"; name = "Hálószoba mozgás"; pin = 12; }
    { id = "konyha_mozgas"; name = "Konyha mozgás"; pin = 32; }
    { id = "akos_szoba_mozgas"; name = "Ákos szoba mozgás"; pin = 25; }
  ];

  flake.modules.esphome."hosts/alarm" = {
    imports = with config.flake.modules.esphome; [
      w5500
    ];

    hostPlatform = "esp32";
    settings = {
      esphome.friendly_name = "Riasztó";
      esp32 = {
        board = "wemos_d1_mini32";
        framework = {
          type = "esp-idf";
          advanced = {
            minimum_chip_revision = "3.1";
            sram1_as_iram = true;
          };
        };
      };

      ethernet = {
        clk_pin = 18;
        mosi_pin = 19;
        miso_pin = 23;
        cs_pin = 5;
        interrupt_pin = 26;
        reset_pin = 33;
        clock_speed = "8MHz";
      };

      alarm_control_panel = [{
        platform = "template";
        id = "riaszto";
        name = "None";
        arming_away_time = "90s";
        pending_time = "30s";
        restore_mode = "RESTORE_DEFAULT_DISARMED";
        binary_sensors = map
          (x: {
            input = x.id;
            trigger_mode = x.trigger_mode or "delayed_follower";
          })
          pirSensors;
        on_triggered."then" = [{ "switch.turn_on" = "siren"; }];
        on_cleared."then" = [{ "switch.turn_off" = "siren"; }];
      }];

      binary_sensor =
        let
          mkPirSensor = { pin, id, name, ... }: {
            platform = "gpio";
            inherit id name;
            device_class = "motion";
            pin = {
              number = pin;
              mode = "INPUT_PULLUP";
            };
          };
        in
        map mkPirSensor pirSensors;

      switch = [{
        platform = "gpio";
        id = "siren";
        name = "Sziréna";
        icon = "mdi:alarm-bell";
        pin = 27;
      }];
    };
  };
in
{ inherit flake; }
