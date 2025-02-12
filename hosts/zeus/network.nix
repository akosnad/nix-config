{ config, ... }:
{
  networking = {
    hostName = "zeus";
    hosts = {
      # this is to fix hostname in servarr docker containers
      "${config.devices."${config.networking.hostName}".ip}" = [ config.networking.hostName "${config.networking.hostName}.local" "${config.networking.hostName}.${config.networking.domain}" ];
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
          Kind = "bridge";
          Name = "br0";
          MACAddress = config.devices.zeus.mac;
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
          DHCP = true;
          IPv6AcceptRA = true;
          LLDP = true;
          IPv6SendRA = false;
          DHCPPrefixDelegation = false;
        };
      };
    };
  };
}
