{ config, ... }:
{
  config.flake.devices.hades-controller = {
    mac = "E4:B3:23:F8:0B:8C";
    ip = "10.4.2.5";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  config.flake.modules.esphome."hosts/hades-controller" = {
    imports = with config.flake.modules.esphome; [
      wifi-signal
    ];

    settings = {
      esphome.friendly_name = "Hades controller";
      esp32 = {
        variant = "esp32s3";
        board = "esp32-s3-devkitc-1";
        flash_size = "4MB";
        framework.type = "esp-idf";
      };

      switch = [{
        platform = "gpio";
        pin = "GPIO7";
        name = "Heating";
        icon = "mdi:radiator";
      }];
    };
  };
}
