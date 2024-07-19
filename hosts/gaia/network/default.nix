{
  imports = [
    ./lan.nix
    ./wan.nix
    ./wifi-ap.nix
    ./nat.nix
    ./adguard.nix
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
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
    "net.ipv6.conf.all.forwarding" = "1";
  };
}
