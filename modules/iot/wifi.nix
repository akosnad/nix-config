{ config, lib, ... }:
let
  devices = config.flake.devices;
in
{
  flake.modules.esphome.wifi = { name, config, ... }:
    let
      isLocalDevice = lib.hasAttr name devices;
    in
    {
      settings = {
        wifi = {
          min_auth_mode = lib.mkIf ({ esp32 = true; esp8266 = true; }.${config.hostPlatform} or false) "WPA2";
          ssid = "!secret wifi_ssid";
          password = "!secret wifi_pass";
          domain = ".home.arpa";
          manual_ip = lib.mkIf isLocalDevice {
            static_ip = devices.${name}.ip;
            subnet = "255.0.0.0";
            gateway = devices.gaia.ip;
            dns1 = devices.gaia.ip;
          };
        };
        sensor = [{
          platform = "wifi_signal";
          name = "Signal";
          update_interval = "10s";
        }];
      };
    };
}
