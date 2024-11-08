{ lib, pkgs, ... }:
let
  commonConfigOptions = {
    device = {
      name = "gaia-router";
      identifiers = [ "gaia-router" ];
    };
    availability_topic = "gaia-router/availability";
    device_class = "speed";
    state_class = "measurement";
  };

  internetDownSpeedConfig = commonConfigOptions // {
    name = "Internet Download Speed";
    state_topic = "gaia-router/internet_rx";
    unit_of_measurement = "Mbit/s";
    unique_id = "internet_down_speed";
  };

  internetUpSpeedConfig = commonConfigOptions // {
    name = "Internet Upload Speed";
    state_topic = "gaia-router/internet_tx";
    unit_of_measurement = "Mbit/s";
    unique_id = "internet_up_speed";
  };

  linkCommonConfig = {
    inherit (commonConfigOptions) device availability_topic;
    device_class = "connectivity";
    payload_on = "true";
    payload_off = "false";
  };

  entities = [ internetDownSpeedConfig internetUpSpeedConfig ];

  script = pkgs.writeShellApplication {
    name = "ha-network-monitor";
    bashOptions = [ "errexit" "nounset" "pipefail" /* "xtrace" */ ];
    runtimeInputs = with pkgs; [ mosquitto python3 iproute2 jq ];
    text = /* bash */ ''
      mqttEndpoint="mqtt://127.0.0.1"

      # send entity configs
      ${builtins.concatStringsSep "\n" (map (entity: /* bash */ ''
        mosquitto_pub \
          -L "$mqttEndpoint/homeassistant/sensor/${entity.unique_id}/config" \
          -m '${builtins.toJSON entity}' \
          -r -q 1
      '') entities)}

      # setup availability topic
      function on_exit() {
        mosquitto_pub -L "$mqttEndpoint/${commonConfigOptions.availability_topic}" -m "offline" -r -q 1
      }
      trap on_exit EXIT
      mosquitto_pub -L "$mqttEndpoint/${commonConfigOptions.availability_topic}" -m "online" -r -q 1

      # start monitoring
      last_rx="0"
      last_tx="0"
      last_sample="0"
      window_size=10
      while true; do
        raw="$(ifstat -a -j)"
        devs="$(ip --json route show table mwan | jq -r '.[] | .dev')"
        while read -r d; do
          # send link entity config
          mosquitto_pub -L "$mqttEndpoint/homeassistant/binary_sensor/$d/config" \
            -m "$(jq -n --arg d "$d" --arg state_topic "gaia-router/link/$d" --argjson linkCommonConfig '${builtins.toJSON linkCommonConfig}' '$linkCommonConfig + {name: $d, unique_id: $d, state_topic: $state_topic}')" \
            -r -q 1

          # send link state
          up="$(ip --json link show "$d" | jq '.[].flags | index("UP") != null')"
          mosquitto_pub -L "$mqttEndpoint/gaia-router/link/$d" -m "$up" -q 1

          if [[ "$up" == "true" ]]; then
            active_dev="$d"
          fi
        done <<< "$devs"
        rx_bytes="$(echo "$raw" | jq -r ".kernel.$active_dev.rx_bytes")"
        tx_bytes="$(echo "$raw" | jq -r ".kernel.$active_dev.tx_bytes")"
        # milliseconds since epoch
        sample_time="$(date +%s%3N)"

        if [[ "$last_sample" == "0" ]]; then
          last_rx="$rx_bytes"
          last_tx="$tx_bytes"
          last_sample="$sample_time"
        else
          actual_window_size="$(python3 -c "print(($sample_time - $last_sample) / 1000)")"
          last_rx_diff="$(python3 -c "print('{:0.3f}'.format(($rx_bytes - $last_rx) / 1024 / 1024 * 8 / $actual_window_size))")"
          last_tx_diff="$(python3 -c "print('{:0.3f}'.format(($tx_bytes - $last_tx) / 1024 / 1024 * 8 / $actual_window_size))")"
          # FIXME: this is a hack to avoid sending negative values
          if [[ "$(python3 -c "print($last_rx_diff > 0)")" == "True" && "$(python3 -c "print($last_tx_diff > 0)")" == "True" ]]; then
            mosquitto_pub -L "$mqttEndpoint/${internetDownSpeedConfig.state_topic}" -m "$last_rx_diff" -q 1
            mosquitto_pub -L "$mqttEndpoint/${internetUpSpeedConfig.state_topic}" -m "$last_tx_diff" -q 1
          fi
          last_rx="$rx_bytes"
          last_tx="$tx_bytes"
          last_sample="$sample_time"
        fi

        sleep $window_size
      done
    '';
  };
in
{
  systemd.services.ha-network-monitor = {
    description = "Home Assistant network monitoring";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 3;

      ExecStart = lib.getExe script;
    };
  };
}
