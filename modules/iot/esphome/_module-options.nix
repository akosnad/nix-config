{ lib, config, name, inputs, ... }:
let
  inherit (lib) mkOption types;

  esphome = {
    freeformType = types.attrs;
    options = {
      name = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      friendly_name = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      project = {
        name = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        version = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
      };
    };
  };

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
        type = types.nullOr (types.strMatching "^mdi:[a-z\-]+$");
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

  light = {
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
        type = types.nullOr (types.strMatching "^mdi:[a-z\-]+$");
        default = null;
      };
      platform = mkOption {
        type = types.str;
      };
    };
  };

  wifi = {
    freeformType = types.attrs;
    options = {
      ssid = mkOption {
        type = types.nullOr types.str;
      };
      password = mkOption {
        type = types.nullOr types.str;
      };
      domain = mkOption {
        type = types.nullOr types.str;
      };
      networks = mkOption {
        type = types.nullOr (types.listOf types.attrs);
      };
      manual_ip = mkOption {
        type = types.nullOr types.attrs;
      };
    };
  };

  ethernet = {
    freeformType = types.attrs;
    options = {
      manual_ip = mkOption {
        type = types.nullOr types.attrs;
      };
      domain = mkOption {
        type = types.nullOr types.str;
      };
      mac_address = mkOption {
        type = types.nullOr types.str;
      };
    };
  };

  settings = {
    freeformType = types.attrs;
    options = {
      esphome = mkOption {
        type = types.submodule esphome;
        apply = cfg: if cfg == null then null else (lib.filterAttrsRecursive (_: val: val != null) cfg);
      };
      sensor = mkOption {
        type = types.nullOr (types.listOf (types.submodule sensor));
        default = null;
        apply = cfg: if cfg == null then null else lib.map (item: (lib.filterAttrsRecursive (_: val: val != null) item)) cfg;
      };
      light = mkOption {
        type = types.nullOr (types.listOf (types.submodule light));
        default = null;
        apply = cfg: if cfg == null then null else lib.map (item: (lib.filterAttrsRecursive (_: val: val != null) item)) cfg;
      };
      wifi = mkOption {
        type = types.nullOr (types.submodule wifi);
        apply = cfg: if cfg == null then null else (lib.filterAttrsRecursive (_: val: val != null) cfg);
        default = null;
      };
      ethernet = mkOption {
        type = types.nullOr (types.submodule ethernet);
        apply = cfg: if cfg == null then null else (lib.filterAttrsRecursive (_: val: val != null) cfg);
        default = null;
      };
    };
  };
in
{
  options = {
    buildPlatform = mkOption {
      description = ''
        The build host platform. More specifically, the system that will run ESPHome code generation and compilation.

        This is in the same spirit as with NixOS configurations; just like the option `nixpkgs.buildPlatform`.
        Note that usually `buildPlatform == hostPlatform` holds for NixOS configurations, and if they differ,
        that implies the system is cross-compiled. In the case of ESPHome hosts, cross compilation is always the case,
        because `hostPlatform` isn't defined (nor makes much sense), only `buildPlatform` is relevant.

        Changing to another platform will cause the configuration to rebuild (and pushing an OTA if you have `autoUpdate.enable`d).
      '';
      type = types.str;
      default = "x86_64-linux";
    };
    yaml = mkOption {
      description = ''
        The generated YAML configuration to be passed to `esphome run <device>.yaml`.
      '';
      type = types.package;
    };
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

  config.yaml =
    let
      pkgs = import inputs.nixpkgs { system = config.buildPlatform; };
      deviceSettingsFormat = pkgs.formats.yaml { };

      # borrowed from nixpkgs: https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/home-automation/home-assistant.nix
      #
      # Post-process YAML output to add support for YAML functions, like
      # secrets or includes, by naively unquoting strings with leading bangs
      # and at least one space-separated parameter.
      # https://www.home-assistant.io/docs/configuration/secrets/
      renderDeviceSettingsFile =
        fn: yaml:
        pkgs.runCommandLocal fn { } ''
          temp="${fn}"
          cp ${deviceSettingsFormat.generate fn yaml} $temp
          storeHash=$(sed -E 's/^\/nix\/store\/([0-9a-z]{32}).*$/\1/' <<<"$out")
          ${lib.getExe pkgs.yq-go} -i ".esphome.project.version = \"$storeHash\"" $temp
          sed -i -e "s/'\!\([a-z_]\+\) \(.*\)'/\!\1 \2/;s/^\!\!/\!/;" $temp

          # generate fake secrets for validation
          while IFS= read -r line; do
            if [[ "$line" =~ !secret[[:space:]]+([^[:space:]]+) ]];then
              value="''${BASH_REMATCH[1]}"
              echo "''${value}: 12345678ABC" >> secrets.yaml
            fi
          done < "$temp"

          # validate config
          ${lib.getExe pkgs.esphome} config $temp || exit 1

          cp $temp $out
        '';
    in
    renderDeviceSettingsFile "${name}.yaml" config.settings;
}
