{ pkgs, lib, hostName, ... }:
let
  endpoint = "mqtt://gaia";
  availability_topic = "${hostName}_availability";
  command_topic = "${hostName}_notify";
  object_id = "${hostName}_nixos_notify";

  ha_entity_config = pkgs.writeText "ha_entity_config.json" (builtins.toJSON {
    availability = [{
      topic = availability_topic;
    }];
    device = {
      name = hostName;
    };
    name = "${hostName} NixOS notify";
    qos = 1;
    inherit object_id command_topic;
    unique_id = object_id;
  });

  script = pkgs.writeShellApplication {
    name = "mqtt-notification-daemon";

    runtimeInputs = with pkgs; [ mosquitto nettools libnotify jq ];

    text = /* bash */ ''
      mosquitto_pub \
        -L "${endpoint}/${availability_topic}" \
        -m 'online' \
        -r -q 1

      mosquitto_pub \
        -L "${endpoint}/homeassistant/notify/${object_id}/config" \
        -f "${ha_entity_config}" \
        -r -q 1

      mosquitto_sub \
        -L "${endpoint}/${command_topic}" \
        -i "${object_id}" \
        --will-topic "${availability_topic}" \
        --will-payload 'offline' \
        --will-qos 1 \
        --will-retain \
        -k 30 \
        | while read -r message; do
          echo "Received message: ''${message}"

          jq -e .body <<< "$message" || continue

          title=$(echo "$message" | jq -r '.title')
          if [[ "$title" == "null" ]]; then
            title=""
          fi
          body=$(echo "$message" | jq -r '.body')
          if [[ "$body" == "null" ]]; then
            body=""
          fi
          notify-send -a MQTT "$title" "$body"
      done
    '';
  };
in
{
  systemd.user.services.mqtt-notify = {
    Unit = {
      Description = "MQTT notification daemon";
      After = "graphical-session.target";
    };
    Service = {
      ExecStart = lib.getExe script;
      Restart = "on-failure";
      RestartSec = "2s";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
