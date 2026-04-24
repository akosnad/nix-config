{ config, ... }:
{
  config.flake.devices.gate-external-button = {
    mac = "FC:E8:C0:DF:9C:58";
    ip = "10.4.2.8";
    blockInternetAccess = true;
    connectionMedium = "wifi";
  };

  config.flake.modules.esphome."hosts/gate-external-button" = {
    imports = with config.flake.modules.esphome; [
      wifi-signal
      grow-fp-reader
    ];

    fp-reader = {
      sensing_pin = 27;
      tx_pin = 32;
      rx_pin = 25;
    };
    settings = {
      esp32 = {
        board = "lolin32";
        framework.type = "esp-idf";
      };
    };
  };
}
