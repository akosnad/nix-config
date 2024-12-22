{ pkgs, lib, ... }:
let
  primaryGateway = "10.10.0.1";

  transientAddr = "192.168.51.254";
  # Android ethernet tethering seems to have this address consistently
  transientGateway = "192.168.51.128";

  failoverScript = pkgs.writeShellApplication {
    name = "wan-failover";
    runtimeInputs = with pkgs; [ coreutils iputils iproute2 ];
    text = ''
      set_primary_route() {
        ip route del default via ${transientGateway} dev br-lan 2>/dev/null || true
        ip route replace default via ${primaryGateway} dev wan0 metric 100
      }

      set_transient_route() {
        ip route del default via ${primaryGateway} dev wan0 2>/dev/null || true
        ip route replace default via ${transientGateway} dev br-lan metric 200
      }

      while true; do
        if ping -I wan0 -c 2 -W 2 1.1.1.1 > /dev/null 2>&1; then
          set_primary_route
        else
          set_transient_route
        fi
        sleep 5
      done
    '';
  };
in
{
  systemd.network.networks."50-br-lan" = {
    networkConfig = {
      Address = [ "${transientAddr}/24" ];
    };
    routes = [{
      Table = "main";
      Destination = "0.0.0.0/0";
      Protocol = "static";
      Gateway = transientGateway;
      Metric = 2000;
    }];
  };

  networking.nftables.tables = {
    nat-transient-wan = {
      family = "ip";
      content = /* nftables */ ''
        chain post {
          type nat hook postrouting priority srcnat; policy accept;
          ip saddr 10.20.0.0/24 ip daddr 0.0.0.0/0 oifname "br-lan" counter masquerade comment "br-lan transient-wan";
        }
      '';
    };
  };

  systemd.services."wan-failover" = {
    description = "WAN failover";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = lib.getExe failoverScript;
      Restart = "always";
      RestartSec = 3;
    };
  };
}
