{ pkgs, lib, ... }:
{
  systemd.services.wan-failover = {
    description = "WAN failover";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 3;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "wan-failover";
        runtimeInputs = with pkgs; [ iproute2 iputils curl gawk ];
        text = ''
          PRIMARY_IF="wan0"
          BACKUP_IF="wan-rndis"

          # number of consecutive health check fails to consider when switching to/from backup routes
          HEALTH_THRESHOLD=3
          # seconds between each health check
          SLEEP_INTERVAL=5

          ###
    
          failure_count=0

          healthcheck() {
            local result="pass"
            curl --interface "$PRIMARY_IF" -s --connect-timeout 3 https://www.google.com -o /dev/null || result="curl failed"
            ping -I "$PRIMARY_IF" -c3 -W 3 1.1.1.1 &>/dev/null || result="ping failed"

            echo "healthcheck result: $result"
            if [ "$result" != "pass" ]; then
              return 1
            fi
            return 0
          }

          ensure_routes() {
            local iface
            local gateway
            local gateway_bk

            iface="$1"
            gateway="$(ip route get 1.1.1.1 dev "$iface" | head -n1 | awk '{print $3}')"

            ip route replace default via "$gateway" dev "$iface" metric 100

            if [[ "$iface" == "$PRIMARY_IF" ]]; then
              gateway_bk="$(ip route get 1.1.1.1 dev "$BACKUP_IF" | head -n1 | awk '{print $3}')"
              ip route replace default via "$gateway_bk" dev "$BACKUP_IF" metric 200
            else
              gateway_bk="$(ip route get 1.1.1.1 dev "$PRIMARY_IF" | head -n1 | awk '{print $3}')"
              ip route replace default via "$gateway_bk" dev "$PRIMARY_IF" metric 200
            fi
          }

          while true; do
            if healthcheck; then
              failure_count=0
              ensure_routes "$PRIMARY_IF"
            else
              failure_count=$((failure_count+1))
              echo "health check failed! (''${failure_count}/''${HEALTH_THRESHOLD})"
              if [ "$failure_count" -ge "$HEALTH_THRESHOLD" ]; then
                ensure_routes "$BACKUP_IF"
              fi
            fi
            sleep "$SLEEP_INTERVAL"
          done
        '';
      });
    };
  };
}
