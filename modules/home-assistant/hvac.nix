{ lib, config, ... }:
{
  config.flake.modules.nixos.home-assistant =
    { pkgs, ... }:
    let
      gree-hvac-mqtt-bridge = pkgs.buildNpmPackage rec {
        pname = "gree-hvac-mqtt-bridge";
        version = "1.2.2";

        src = pkgs.fetchFromGitHub {
          owner = "aaronsb";
          repo = pname;
          rev = "v${version}";
          hash = "sha256-YoSAbxKC7vB/7r9HcN74GgyzEPBeZLRqE3M2QW/1gJc=";
        };

        npmDepsHash = "sha256-g4i7ruGTFq/Bm1uBYvlvV8JOD2N6VZuZZmSuMuJb/50=";
        dontNpmBuild = true;

        postInstall = ''
          # remove broken symlinks
          find $out/lib/node_modules -xtype l -type l -delete
        '';

        passthru.entrypoint = "index.js";
      };

      topicPrefix = "home/helios";
      bridge = "${gree-hvac-mqtt-bridge}/lib/node_modules/gree-hvac-mqtt-bridge/index.js";
      bridgeScript = pkgs.writeShellApplication {
        name = "gree-hvac-mqtt-bridge-start";
        runtimeInputs = [ pkgs.nodejs ];
        text = ''
          node ${bridge} \
            --hvac-host="${config.flake.devices.helios.ip}" \
            --mqtt-broker-url="mqtt://localhost" \
            --mqtt-topic-prefix="${topicPrefix}" \
            --mqtt-retain="true" \
            --mqtt-username="" \
            --mqtt-password=""
        '';
      };
    in
    {
      systemd.services.gree-hvac-mqtt-bridge = {
        description = "Gree HVAC MQTT Bridge";
        wantedBy = [ "multi-user.target" ];
        wants = [ "home-assistant.service" ];
        after = [
          "network.target"
          "home-assistant.service"
        ];
        partOf = [ "home-assistant.service" ];
        serviceConfig = {
          Restart = "always";
          RestartSec = 3;

          # this is a hack to wait for home assistant to load, only then publish the state.
          # otherwise the entity will be shown as unavailable initally.
          #
          # TODO: shouldn't the app solve this by retaining messages?
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 60";

          ExecStart = "${lib.getExe bridgeScript}";
        };
      };

      services.home-assistant.config = {
        mqtt.climate = {
          name = "helios";

          current_temperature_topic = "${topicPrefix}/temperature/get";
          temperature_command_topic = "${topicPrefix}/temperature/set";
          temperature_state_topic = "${topicPrefix}/temperature/get";
          mode_state_topic = "${topicPrefix}/mode/get";
          mode_command_topic = "${topicPrefix}/mode/set";
          fan_mode_state_topic = "${topicPrefix}/fanspeed/get";
          fan_mode_command_topic = "${topicPrefix}/fanspeed/set";
          swing_mode_state_topic = "${topicPrefix}/swingvert/get";
          swing_mode_command_topic = "${topicPrefix}/swingvert/set";
          #power_state_topic = "${topicPrefix}/power/get";
          power_command_topic = "${topicPrefix}/power/set";

          payload_off = 0;
          payload_on = 1;
          modes = [
            "off"
            "auto"
            "cool"
            "heat"
            "dry"
            "fan_only"
          ];
          swing_modes = [
            "default"
            "full"
            "fixedTop"
            "fixedMidTop"
            "fixedMid"
            "fixedMidBottom"
            "fixedBottom"
            "swingBottom"
            "swingMidBottom"
            "swingMid"
            "swingMidTop"
            "swingTop"
          ];
          fan_modes = [
            "auto"
            "low"
            "mediumLow"
            "medium"
            "mediumHigh"
            "high"
          ];
        };
      };
    };
}
