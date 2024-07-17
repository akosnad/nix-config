{
  networking = {
    hostName = "gaia";
    networkmanager.enable = false;
    useDHCP = false;
    useNetworkd = true;
    firewall.enable = true;
  };
  systemd.network = {
    netdevs = {
      br-lan = {
        netdevConfig = {
          "Kind" = "bridge";
          "Name" = "br-lan";
        };
      };
    };
    networks = {
      "br-lan-bind" = {
        matchConfig."Name" = "end0";
        networkConfig."Bridge" = "br-lan";
      };
      "br-lan" = {
        matchConfig."Name" = "br-lan";
        networkConfig = {
          # TODO: change after deployment
          #"IPv6SendRA" = true;
          #"Address" = "10.20.0.2/24";
          #"Gateway" = "10.10.0.1";
          #"DNS" = [ "127.0.0.1" "::1" ];
          "DHCP" = true;
          "IPv6AcceptRA" = true;
        };
      };
      wan = {
        # TODO: use actual interface name
        matchConfig."Name" = "eth1";
        networkConfig = {
          "DHCP" = true;
          "IPv6AcceptRA" = true;
        };
      };
    };
  };
}
