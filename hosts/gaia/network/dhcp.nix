{ config, ... }:
let
  gatewayIp = builtins.head (builtins.split "/" config.systemd.network.networks."50-br-lan".networkConfig.Address);
  dhcpRange = {
    subnet = "255.255.0.0";
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
      mac = "52:54:00:64:11:7B";
      ip = "10.20.0.36";
      name = "homeassistant";
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
  ];

in
{
  services.dnsmasq = {
    enable = true;
    settings = {
      port = "";
      inherit domain;
      local = "/${domain}/";
      interface = "br-lan";
      addn-hosts = "/etc/hosts";
      stop-dns-rebind = true;
      rebind-localhost-ok = true;
      rebind-domain-ok = [ "fzt.one" ];
      dhcp-broadcast = "tag:needs-broadcast";

      # Bogus hostname
      dhcp-ignore-names = "tag:dhcp_bogus_hostname";
      dhcp-name-match = [
        "set:dhcp_bogus_hostname,localhost"
        "set:dhcp_bogus_hostname,wpad"
      ];
      bogus-priv = true;

      dhcp-range = with dhcpRange; [ "set:lan,${ipPrefix}.${lower},${ipPrefix}.${upper},${subnet},${leaseTime}" ];
      dhcp-option = [
        # Gateway
        "lan,3,${gatewayIp}"
        # DNS server
        "lan,6,${gatewayIp}"
      ];

      # Static leases
      dhcp-host = builtins.map (host: "${host.mac},${host.ip},${host.name}") staticLeases;
    };
  };

  networking.hosts = builtins.listToAttrs (builtins.map
    (host: {
      name = host.ip;
      value = [ "${host.name}.${domain}" host.name ];
    })
    staticLeases);
}
