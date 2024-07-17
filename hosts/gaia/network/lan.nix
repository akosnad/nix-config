{
  systemd.network = {
    # Raspberry Pi's internal ethernet port
    links."10-lan0" = {
      matchConfig.PermanentMACAddress = "dc:a6:32:aa:3c:d1";
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
          # TODO: change after deployment
          #"IPv6SendRA" = true;
          #"Address" = "10.20.0.2/24";
          #"Gateway" = "10.10.0.1";
          #"DNS" = [ "127.0.0.1" "::1" ];
          DHCP = true;
          IPv6AcceptRA = true;
        };
      };
    };
  };
}
