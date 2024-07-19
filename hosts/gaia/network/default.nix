{
  imports = [
    ./lan.nix
    ./wan.nix
    ./wifi-ap.nix
  ];

  networking = {
    hostName = "gaia";
    useDHCP = false;
    networkmanager.enable = false;
    useNetworkd = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = [ "br-lan" ];
    };
  };
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
    "net.ipv6.conf.all.forwarding" = "1";
  };
}
