# TODO: this is a cheap and dumb hack. please no.
{ pkgs, lib, ... }:
let
  script = pkgs.writeShellApplication {
    name = "alarm-fix";
    runtimeInputs = with pkgs; [ espflash mosquitto coreutils-full ];
    text = ''
      function do_reset() {
        until timeout 5s espflash -S reset; do
          echo reset failed, retrying...
          sleep 3
        done
      }

      while IFS= read -r line; do
        now="$(date '+%Y.%m.%d. %H:%M:%S')"
        echo "[$now] $line"
        if [[ "$line" == "offline" ]]; then
          echo resetting...
          do_reset
          echo reset was successful.
        fi
      done < <(mosquitto_sub -t gaia_alarm/availability)
    '';
  };
in
{
  systemd.services.alarm-fix = {
    after = [ "network.target" "mosquitto.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = lib.getExe script;
  };
}
