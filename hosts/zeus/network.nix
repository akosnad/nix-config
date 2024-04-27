{
  networking = {
    hostName = "zeus";
    networkmanager.enable = false;
    useDHCP = false;
    useNetworkd = true;
    firewall = {
      allowedTCPPorts = [
        80 443 # webserver
        32400 8324 32469 # plex
      ];
      allowedUDPPorts = [
        1900 5353 32410 32412 32413 32414 # plex
      ];
    };
  };
  systemd.network = {
    netdevs = {
      br0 = {
        netdevConfig = {
          "Kind" = "bridge";
          "Name" = "br0";
        };
      };
    };
    networks = {
      "br0-bind" = {
        matchConfig."Name" = "en*";
        networkConfig."Bridge" = "br0";
      };
      br0 = {
        matchConfig."Name" = "br0";
        networkConfig = {
          "DHCP" = "ipv6";
          "IPv6AcceptRA" = true;
          "IPv6SendRA" = false;
          "DHCPPrefixDelegation" = false;
          "Address" = "10.20.0.4/24";
          "Gateway" = "10.20.0.2";
          "DNS" = [ "10.20.0.2" "fc18:7681::1" ];
        };
      };
    };
  };
}
