{
  systemd.network = {
    # USB Ethernet adatper
    links."10-wan0" = {
      matchConfig.PermanentMACAddress = "7c:c2:c6:1d:ed:72";
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
        };
        cakeConfig = {
          Bandwidth = "500M";
          FlowIsolationMode = "src-host";
          NAT = true;
          PriorityQueueingPreset = "diffserv4";
        };
      };

      "31-bond-wan-slaves-bind" = {
        matchConfig.Name = "wan*";
        networkConfig.Bond = "bond-wan";
      };

      "50-bond-wan" = {
        matchConfig.Name = "bond-wan";
        networkConfig = {
          DHCP = true;
          IPv6AcceptRA = true;
          IPForward = "ipv6";
          LLDP = true;
        };
        routingPolicyRules = [{
          routingPolicyRuleConfig = {
            OutgoingInterface = "bond-wan";
            Table = 200;
            Priority = 16384;
          };
        }];
        routes = [{
          routeConfig = {
            Table = 200;
            Destination = "0.0.0.0/0";
            Protocol = "static";
            Gateway = "_dhcp4";
          };
        }];
      };
    };

    config.routeTables = {
      mwan = 200;
    };
  };
}
