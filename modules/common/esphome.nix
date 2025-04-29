{ lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  options = {
    autoUpdate = {
      enable = mkOption {
        description = ''
          Whether to enable OTA updater service for this device.
        '';
        type = types.bool;
        default = true;
      };
      onCalendar = mkOption {
        description = ''
          Schedule for OTA updates.
        
          The value is passed to the systemd timer unit's OnCalendar.
        '';
        type = types.str;
        default = "*-*-* 02:00:00";
      };
    };
    settings = mkOption {
      description = ''
        Settings for the device to pass to ESPHome.
      '';
      example = {
        esphome = {
          name = "esp1";
          platform = "ESP8266";
          board = "d1_mini";
        };
        logger = { };
        api = { };
        ota = { };
        wifi = {
          ssid = "Stuff";
          password = "!secret wifi_pass";
        };
      };
      type = types.attrs;
      default = { };
    };
  };
}
