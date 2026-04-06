{ lib, ... }:
let
  inherit (lib) types mkOption;

  configurations = mkOption {
    description = ''
      ESPHome device configurations.
    '';
    type = types.attrsOf types.attrs;
    default = { };
  };
in
{
  options.flake.esphomeHosts = configurations;

  config.flake.modules.nixos.base = {
    options.services.esphome-updater = {
      enable = lib.mkOption {
        description = ''
          Enable creation of ESPHome device OTA updater services
        '';
        type = types.bool;
        default = false;
      };
      inherit configurations;
    };
  };
}
