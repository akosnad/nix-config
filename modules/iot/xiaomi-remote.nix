{ lib, inputs, ... }:
let
  inherit (lib) mkOption types;

  press = { config, ... }: {
    options = {
      key = mkOption {
        type = types.enum [ "on" "off" "sun" "+" "m" "-" ];
      };
      keycode = mkOption {
        type = types.int;
        readOnly = true;
        default = {
          "on" = 0;
          "off" = 1;
          "sun" = 2;
          "+" = 3;
          "m" = 4;
          "-" = 5;
        }.${config.key};
      };
      "then" = mkOption {
        type = types.listOf types.attrs;
        default = [ ];
      };
    };
  };
in
{
  config.flake.modules.esphome.xiaomi-remote = {
    options = {
      settings.xiaomi_ylyk01yl = {
        mac_address = mkOption {
          description = ''
            Bluetooth MAC address of the remote.
          '';
          type = types.str;
        };
        on_press = mkOption {
          type = types.listOf (types.submodule press);
          default = [ ];
          apply = cfg: lib.map (item: (lib.filterAttrs (n: _: n != "key") item)) cfg;
        };
        on_long_press = mkOption {
          type = types.listOf (types.submodule press);
          default = [ ];
          apply = cfg: lib.map (item: (lib.filterAttrs (n: _: n != "key") item)) cfg;
        };
      };
    };

    config.settings = {
      external_components = [
        {
          source = {
            type = "local";
            path = "${inputs.esphome-yeelight-ceiling-light.outPath}/components";
          };
        }
      ];
      esp32_ble_tracker.scan_parameters = {
        interval = "150ms";
        window = "150ms";
        duration = "1min";
        active = false;
      };
      xiaomi_ylyk01yl = { };
    };
  };
}
