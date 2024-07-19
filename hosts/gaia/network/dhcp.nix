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
in
{
  services.dnsmasq = {
    enable = true;
    settings = {
      port = "";
      domain = "home.arpa";
      local = "/home.arpa/";
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
      dhcp-host = [
        "96:5F:26:76:7C:8C,10.20.0.3,ap1"
        "28:d1:27:be:7b:3d,10.20.0.5,ap2"
        "3C:CD:57:73:05:22,10.20.0.6,ap3"
        "52:54:00:64:11:7B,10.20.0.36,homeassistant"
        "F4:91:1E:F6:E3:A3,10.20.0.30,helios"
        "A8:5E:45:CD:FC:8A,10.20.0.96,kratos"
        "2C:27:D7:1F:98:BD,10.20.0.4,zeus"
      ];
    };
  };
}
