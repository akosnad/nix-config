let
  networkConfig = {
    DHCP = true;
    IPv6AcceptRA = true;
    LLDP = true;
  };
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
