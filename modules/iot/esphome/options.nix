{ lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  config.flake.modules.nixos.base = {
    options.services.esphome-updater = {
      enable = mkOption {
        description = ''
          Enable creation of ESPHome device OTA updater services
        '';
        type = types.bool;
        default = false;
      };
    };
  };
}
