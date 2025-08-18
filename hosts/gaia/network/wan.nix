let
  networkConfig = {
    DHCP = true;
    IPv6AcceptRA = true;
    LLDP = true;
  };

  mkRoutes = { name, metric ? 1024 }: [
    {
      Table = name;
      Destination = "0.0.0.0/0";
      Protocol = "static";
      Gateway = "_dhcp4";
      Metric = metric;
    }
    {
      Table = name;
      Destination = "::/0";
      Protocol = "static";
      Gateway = "_ipv6ra";
      Metric = metric;
    }
  ];
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
        routes = mkRoutes { name = "wan-primary"; };
        routingPolicyRules = [{
          Table = "wan-primary";
          Priority = 6000;
          FirewallMark = "0xC8/0xFF";
        }];
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
        routes = mkRoutes { name = "wan-failover"; };
        routingPolicyRules = [{
          Table = "wan-failover";
          Priority = 6000;
          FirewallMark = "0xC9/0xFF";
        }];
        cakeConfig = {
          Bandwidth = "30M";
          AutoRateIngress = true;
          FlowIsolationMode = "src-host";
          PriorityQueueingPreset = "diffserv4";
        };
      };
    };

    config.routeTables = {
      wan-primary = 200;
      wan-failover = 201;
    };
  };
}
