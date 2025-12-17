{ common, ... }:
{
  settings = {
    esphome.friendly_name = "Előszoba nyitásérzékelő";
    esp32 = {
      board = "lolin32";
      framework.type = "esp-idf";
    };

    sensor = with common.sensorPresets; [
      wifi_signal
    ];

    binary_sensor = [{
      id = "ajto";
      name = "Ajtó";
      platform = "gpio";
      device_class = "door";
      pin = {
        number = 27;
        inverted = false;
        mode = { input = true; pullup = true; };
      };
      filters = [{ delayed_on_off = "100ms"; }];
    }];
  };
}
