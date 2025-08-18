{ pkgs, lib, ... }:
{
  networking.nftables.tables.wan-failover = {
    family = "inet";
    content = ''
      chain pre {
        type filter hook prerouting priority mangle;

        # always restore conmark to packet mark
        jump wan_mark
        meta mark set ct mark
      }

      chain output {
        type route hook output priority mangle;

        # always restore conmark to packet mark (for traffic originating from this host)
        jump wan_mark
        meta mark set ct mark
      }

      chain wan_mark {
        # wan selection handled by failover script
        # defaults to primary here
        ct state new ct mark set 200
      }
    '';
  };

  systemd.services.wan-failover = {
    description = "WAN failover";
    wants = [ "network.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "wan-failover";
        runtimeInputs = with pkgs; [ nftables iproute2 iputils curl dnsutils ];
        text = ''
          PRIMARY=200
          FAILOVER=201

          function apply() {
            # nft flush chain inet wan-failover wan_mark
            # nft add rule inet wan-failover wan_mark ct state new ct mark set $1
            handle="$(nft -n -a list chain inet wan-failover wan_mark | grep 'ct mark set' | grep -oP "\d+$")"
            nft replace rule inet wan-failover wan_mark handle "$handle" ct state new ct mark set "$1"
            exit 0
          }

          if ! ping -I wan0 -c 2 -W 2 1.1.1.1 &>/dev/null; then
            echo "ping test failed, failover active"
            apply $FAILOVER
          fi

          echo "all tests passed, primary active"
          apply $PRIMARY

          # TODO: dig and curl based checks
          # problem is, it's not trivial to set source interface using those tools
        '';
      });
    };
  };

  systemd.timers.wan-failover = {
    description = "WAN failover periodic check";
    wantedBy = [ "multi-user.target" ];
    timerConfig = {
      OnBootSec = "10s";
      OnUnitActiveSec = "10s";
    };
  };
}
