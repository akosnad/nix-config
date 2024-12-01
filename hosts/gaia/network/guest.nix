let
  gatewayIp = "192.168.254.1";
  dhcpRange = {
    ipPrefix = "192.168.254";
    lower = "100";
    upper = "200";
    leaseTime = "1h";
  };
in
{
  systemd.network = {
    netdevs."20-br-guest" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br-guest";
      };
    };

    networks."50-br-guest" = {
      matchConfig.Name = "br-guest";
      networkConfig = {
        Address = "${gatewayIp}/24";
        DNS = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];
        IPv6AcceptRA = false;

        # TODO: fix ipv6 forwarding, instead of just disabling it
        IPv6SendRA = false;
        LinkLocalAddressing = false;

        DHCPPrefixDelegation = true;
        LLDP = true;
        MulticastDNS = false;
      };
    };
  };

  networking.nftables.tables = {
    nat-guest = {
      family = "ip";
      content = /* nftables */ ''
        chain pre {
          type nat hook prerouting priority dstnat; policy accept;
        }

        chain post {
          type nat hook postrouting priority srcnat; policy accept;
          iifname "br-guest" oifname "wan0" masquerade comment "masquerade guest -> wan0";
          iifname "br-guest" oifname "wan-rndis" masquerade comment "masquerade guest -> wan-rndis";
        }

        chain out {
          type nat hook output priority mangle; policy accept;
        }
      '';
    };
    filter-guest = {
      family = "inet";
      content = /* nftables */ ''
        chain forward {
          type filter hook forward priority filter; policy accept;

          # block lan access from guest
          iifname "br-guest" oifname "br-lan" reject comment "block guest -> lan";
        }
      '';
    };
  };

  services.dnsmasq.settings = {
    dhcp-range = with dhcpRange; [ "set:guest,${ipPrefix}.${lower},${ipPrefix}.${upper},${leaseTime}" ];
    dhcp-option = [
      # Gateway
      "guest,3,${gatewayIp}"
      # DNS
      "guest,6,1.1.1.1,1.0.0.1"
    ];
  };
}
