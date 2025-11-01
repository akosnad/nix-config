{ common, ... }:
{
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

    sensor = with common.sensorPresets; [
      wifi_signal
    ];
  };
}
