{ pkgs, lib, ... }:
let
  topicPrefix = "home/helios";
  bridge = "${pkgs.nodePackages.gree-hvac-mqtt-bridge}/lib/node_modules/gree-hvac-mqtt-bridge/index.js";
  bridgeScript = pkgs.writeShellApplication {
    name = "gree-hvac-mqtt-bridge-start";
    runtimeInputs = [ pkgs.nodejs ];
    text = ''
      node ${bridge} \
        --hvac-host="10.20.0.30" \
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
    after = [ "network.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 3;
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
}
