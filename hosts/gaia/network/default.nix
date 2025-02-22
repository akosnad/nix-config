{ config, ... }:
let
  inherit (config.networking) domain;
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
    ./block.nix
    ./pxe
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
      filterForward = true; # critical for IPv6 as there is no NAT
      trustedInterfaces = [ "br-lan" "tailscale0" ];
    };
    nameservers = [
      config.devices.gaia.ip
    ];
    hosts = {
      "::1" = [ "localhost" hostName hostnameWithDomain ];
      "127.0.0.1" = [ "localhost" hostName hostnameWithDomain ];
    };
  };
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
    "net.ipv6.conf.all.forwarding" = "1";
  };
  services.openssh.openFirewall = false;
}
