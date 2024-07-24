{
  systemd.network = {
    # Raspberry Pi's internal ethernet port
    links."10-lan0" = {
      matchConfig.PermanentMACAddress = "dc:a6:32:19:bc:79";
      linkConfig.Name = "lan0";
    };

    netdevs."20-br-lan" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br-lan";
      };
    };

    networks = {
      "30-br-lan-bind" = {
        matchConfig.Name = "lan*";
        networkConfig.Bridge = "br-lan";
      };

      "50-br-lan" = {
        matchConfig.Name = "br-lan";
        networkConfig = {
          Address = "10.20.0.1/24";
          DNS = [ "127.0.0.1" "::1" ];
          IPv6AcceptRA = false;
          IPv6SendRA = true;
          DHCPPrefixDelegation = true;
        };
      };
    };
  };
}
