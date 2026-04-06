{ lib, ... }:
let
  inherit (lib) mkOption types;

  sensor = {
    freeformType = types.attrs;
    options = {
      id = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      name = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      icon = mkOption {
        type = types.nullOr (types.strMatching "^mdi:[a-z]+$");
        default = null;
      };
      device_class = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      state_class = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      entity_category = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      platform = mkOption {
        type = types.str;
      };
    };
  };

  settings = {
    freeformType = types.attrs;
    options = {
      sensor = mkOption {
        type = types.nullOr (types.listOf (types.submodule sensor));
        default = null;
        apply = cfg: if cfg == null then null else lib.map (item: (lib.filterAttrsRecursive (_: val: val != null) item)) cfg;
      };
    };
  };
in
{
  options = {
    frameworkVersion = mkOption {
      description = ''
        ESPHome version to use for compiling and updating this device.
        It can be any docker image tag, which can be found at:
        https://github.com/esphome/esphome/pkgs/container/esphome

        It defaults to the ESPHome version found in the updater machine's nixpkgs.
      '';
      type = types.nullOr types.str;
      example = "2025.10";
      default = null;
    };
    autoUpdate = {
      enable = mkOption {
        description = ''
          Whether to enable OTA updater service for this device.
        '';
        type = types.bool;
        default = true;
      };
      schedule = mkOption {
        description = ''
          How often to run OTA updates.

          By default updates are applied immediately after the configuration changes.
          This can be overwritten to have a fixed schedule by setting the value other than null.
          See {manpage}`systemd.time(7)` for the format.
        '';
        type = types.nullOr types.str;
        example = "*-*-* 02:00:00";
        default = null;
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
      type = types.submodule settings;
      default = { };
      apply = cfg: lib.filterAttrsRecursive (_: val: val != null) cfg;
    };
  };
}
