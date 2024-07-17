{
  systemd.network = {
    # USB Ethernet adatper
    links."10-wan0" = {
      matchConfig.PermanentMACAddress = "00:e0:4c:68:00:5a";
      linkConfig.Name = "wan0";
    };

    netdevs."20-bond-wan" = {
      netdevConfig = {
        Kind = "bond";
        Name = "bond-wan";
      };
      bondConfig.Mode = "active-backup";
    };

    networks = {
      "30-bond-wan0-bind" = {
        matchConfig.Name = "wan0";
        networkConfig = {
          Bond = "bond-wan";
          PrimarySlave = true;
          Address="10.10.0.3/16";
        };
      };

      "31-bond-wan-slaves-bind" = {
        matchConfig.Name = "wan*";
        networkConfig = {
          Bond = "bond-wan";
          DHCP = true;
          IPv6AcceptRA = true;
        };
      };

      # taken from:
      # https://raspberrypi.stackexchange.com/a/104267
      "50-bond-wan" = {
        matchConfig.Name = "bond-wan";
        routingPolicyRules = [{
          routingPolicyRuleConfig = {
            Table = 200;
            Priority = 16384;
            From="10.10.0.3";
          };
        }];
        routes = [{
          routeConfig = {
            Table = 200;
            Destination = "0.0.0.0/0";
            Protocol = "static";
            Gateway = "10.10.0.1";
            PreferredSource = "10.10.0.3";
          };
        }];
      };
    };

    config.routeTables = {
      mwan = 200;
    };
  };
}
