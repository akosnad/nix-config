{ common, ... }:
{
  settings = {
    esphome.friendly_name = "Cerberus";
    esp8266.board = "d1_mini";
    wifi.power_save_mode = "none";

    switch = [
      {
        platform = "gpio";
        pin = "D1";
        name = "Gate partial toggle";
        id = "gate_partial_toggle";
        icon = "mdi:gate-arrow-right";
        restore_mode = "ALWAYS_OFF";
        on_turn_on = [{ delay = "500ms"; } { "switch.turn_off" = "gate_partial_toggle"; }];
      }
      {
        platform = "gpio";
        pin = "D2";
        name = "Gate toggle";
        id = "gate_toggle";
        icon = "mdi:gate";
        restore_mode = "ALWAYS_OFF";
        on_turn_on = [{ delay = "500ms"; } { "switch.turn_off" = "gate_toggle"; }];
      }
      {
        platform = "gpio";
        pin = "D5";
        name = "Csengő";
        id = "bell";
        icon = "mdi:bell";
        restore_mode = "ALWAYS_OFF";
        on_turn_on = [{ delay = "2000ms"; } { "switch.turn_off" = "bell"; }];
      }
    ];
    sensor = with common.sensorPresets; [
      wifi_signal
      {
        platform = "ultrasonic";
        trigger_pin = "D8";
        echo_pin = "D7";
        update_interval = "2s";
        name = "Gate door distance";
      }
    ];
    binary_sensor = [
      {
        platform = "gpio";
        pin = "D6";
        name = "Gate Infra";
      }
      {
        platform = "gpio";
        pin = {
          number = "D3";
          inverted = true;
          mode = { pullup = true; input = true; };
        };
        name = "Kapu csengő";
        on_press = { "then" = [{ "switch.turn_on" = "bell"; }]; };
        on_release = { "then" = [{ "switch.turn_off" = "bell"; }]; };
      }
    ];
  };
}
