{
  imports = [
    ./lan.nix
    ./wan.nix
    ./nat.nix
    ./dhcp.nix
    ./adguard.nix
    ./dyndns.nix
  ];

  networking = {
    hostName = "gaia";
    useDHCP = false;
    networkmanager.enable = false;
    useNetworkd = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = [ "br-lan" "tailscale0" ];
    };
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
    domain = "home.arpa";
  };
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
    "net.ipv6.conf.all.forwarding" = "1";
  };
  services.openssh.openFirewall = false;
}
