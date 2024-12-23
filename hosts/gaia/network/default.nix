let
  domain = "home.arpa";
  hostName = "gaia";

  hostnameWithDomain = "${hostName}.${domain}";
in
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
    inherit hostName;
    useDHCP = false;
    networkmanager.enable = false;
    useNetworkd = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      allowPing = false;
      rejectPackets = false; # drop packets instead of rejecting them
      trustedInterfaces = [ "br-lan" "tailscale0" ];
    };
    nameservers = [
      "10.20.0.1"
    ];
    inherit domain;
    hosts = {
      "::1" = [ "localhost" hostName hostnameWithDomain ];
      "127.0.0.1" = [ "localhost" hostName hostnameWithDomain ];
      "10.20.0.4" = [ "frigate" "frigate.${domain}" "repo.fzt.one" ];
    };
  };
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
    "net.ipv6.conf.all.forwarding" = "1";
  };
  services.openssh.openFirewall = false;
}
