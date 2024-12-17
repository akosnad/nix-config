{
  networking.nat = {
    enable = true;
    internalInterfaces = [ "br-lan" ];
    externalInterface = "wan0";
    # TODO: get rid of port forwards
    forwardPorts = [
      # qbittorrent
      { destination = "10.20.0.4:15577"; proto = "tcp"; sourcePort = 15577; }
      { destination = "10.20.0.4:15577"; proto = "udp"; sourcePort = 15577; }

      # SIP
      { destination = "10.20.0.4:5060"; proto = "tcp"; sourcePort = 5060; }
      { destination = "10.20.0.4:5060"; proto = "udp"; sourcePort = 5060; }
    ];
  };

  networking.nftables.tables.nat-rndis = {
    family = "ip";
    content = /* nftables */ ''
      chain pre {
        type nat hook prerouting priority dstnat; policy accept;
      }

      chain post {
        type nat hook postrouting priority srcnat; policy accept;
        iifname "br-lan" oifname "wan-rndis" masquerade comment "from br-lan to wan-rndis";
      }

      chain out {
        type nat hook output priority mangle; policy accept;
      }
    '';
  };
}
