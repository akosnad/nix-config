{
  networking = {
    hostName = "zeus";
    hosts = {
      # this is to fix hostname in servarr docker containers
      "10.20.0.4" = [ "zeus" "zeus.local" "zeus.home.arpa" ];
    };
    networkmanager.enable = false;
    useDHCP = false;
    useNetworkd = true;
    firewall = {
      enable = true;
      allowPing = true;
    };
    nftables.enable = true;
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
          DHCP = "ipv6";
          IPv6AcceptRA = true;
          IPv6SendRA = false;
          DHCPPrefixDelegation = false;
          Address = "10.20.0.4/24";
          Gateway = "10.20.0.1";
          DNS = [ "10.20.0.1" ];
        };
      };
    };
  };
}
