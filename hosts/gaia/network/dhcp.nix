{ config, ... }:
let
  gatewayIp = builtins.head (builtins.split "/" config.systemd.network.networks."50-br-lan".networkConfig.Address);
  dhcpRange = {
    ipPrefix = "10.20.0";
    lower = "10";
    upper = "254";
    leaseTime = "1h";
  };
  domain = "home.arpa";

  staticLeases = [
    {
      mac = "00:00:00:00:00:00";
      ip = "10.20.0.1";
      name = "gaia";
    }
    {
      mac = "96:5F:26:76:7C:8C";
      ip = "10.20.0.3";
      name = "ap1";
    }
    {
      mac = "28:d1:27:be:7b:3d";
      ip = "10.20.0.5";
      name = "ap2";
    }
    {
      mac = "3C:CD:57:73:05:22";
      ip = "10.20.0.6";
      name = "ap3";
    }
    {
      mac = "F4:91:1E:F6:E3:A3";
      ip = "10.20.0.30";
      name = "helios";
    }
    {
      mac = "A8:5E:45:CD:FC:8A";
      ip = "10.20.0.96";
      name = "kratos";
    }
    {
      mac = "2C:27:D7:1F:98:BD";
      ip = "10.20.0.4";
      name = "zeus";
    }
    {
      mac = "4C:50:DD:9E:A3:F5";
      ip = "10.20.0.45";
      name = "arges";
    }
    {
      mac = "44:23:7C:CA:40:4F";
      ip = "10.20.0.231";
      name = "ranarp";
    }
    {
      mac = "6C:3C:7C:35:3E:2B";
      ip = "10.20.0.88";
      name = "kalliope";
    }
    {
      mac = "28:EE:52:41:3F:98";
      ip = "10.20.0.123";
      name = "kp105";
    }
  ];

in
{
  services.dnsmasq = {
    enable = true;
    settings = {
      port = "";

      dhcp-range = with dhcpRange; [ "set:lan,${ipPrefix}.${lower},${ipPrefix}.${upper},${leaseTime}" ];
      dhcp-option = [
        # Gateway
        "lan,3,${gatewayIp}"
        # DNS server
        "lan,6,${gatewayIp}"
      ];

      # Static leases
      dhcp-host = builtins.map (host: "${host.mac},lan,${host.ip},${host.name}") staticLeases;
    };
  };

  networking.hosts = builtins.listToAttrs (builtins.map
    (host: {
      name = host.ip;
      value = [ "${host.name}.${domain}" host.name ];
    })
    staticLeases);
}
