let
  networkConfig = {
    DHCP = true;
    IPv6AcceptRA = true;
    IPForward = "ipv6";
    LLDP = true;
  };

  mkDefaultRoutes = { metric }: [
    {
      routeConfig = {
        Table = "mwan";
        Destination = "0.0.0.0/0";
        Protocol = "static";
        Gateway = "_dhcp4";
        Metric = metric;
      };
    }
    {
      routeConfig = {
        Table = "mwan";
        Destination = "::/0";
        Protocol = "static";
        Gateway = "_ipv6ra";
        Metric = metric;
      };
    }
  ];

  mkDefaultRoutingPolicyRules = { ifname, priority }: [{
    routingPolicyRuleConfig = {
      OutgoingInterface = ifname;
      Table = "mwan";
      Priority = priority;
    };
  }];
in
{
  systemd.network = {
    # USB Ethernet adatper
    links."10-wan0" = {
      matchConfig.PermanentMACAddress = "7c:c2:c6:1d:ed:72";
      linkConfig.Name = "wan0";
    };

    links."11-wan-rndis" = {
      matchConfig.Driver = "rndis_host";
      linkConfig.Name = "wan-rndis";
    };

    networks = {
      "50-wan0" = {
        matchConfig.Name = "wan0";
        inherit networkConfig;
        routes = mkDefaultRoutes { metric = 500; };
        routingPolicyRules = mkDefaultRoutingPolicyRules { ifname = "wan0"; priority = 500; };
        cakeConfig = {
          Bandwidth = "500M";
          FlowIsolationMode = "src-host";
          NAT = true;
          PriorityQueueingPreset = "diffserv4";
        };
      };

      "51-wan-rndis" = {
        matchConfig.Name = "wan-rndis";
        inherit networkConfig;
        routes = mkDefaultRoutes { metric = 1000; };
        routingPolicyRules = mkDefaultRoutingPolicyRules { ifname = "wan-rndis"; priority = 1000; };
        cakeConfig = {
          Bandwidth = "30M";
          AutoRateIngress = true;
          FlowIsolationMode = "src-host";
          PriorityQueueingPreset = "diffserv4";
        };
      };
    };

    config.routeTables = {
      mwan = 200;
    };
  };
}
