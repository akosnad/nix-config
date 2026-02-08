{ lib, config, ... }:
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
    ./wan-failover.nix
  ];

  networking = {
    hostName = "gaia";
    useDHCP = false;
    networkmanager.enable = false;
    useNetworkd = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      allowPing = false;
      rejectPackets = false; # drop packets instead of rejecting them
      filterForward = true; # critical for IPv6 as there is no NAT
      trustedInterfaces = [ "br-lan" ];
      checkReversePath = "loose";
      extraForwardRules = ''
        iifname ${config.services.tailscale.interfaceName} accept comment "tailnet -> LAN access"
        iifname "br-lan" oifname "wan-rndis" accept comment "LAN -> wan-rndis access"
      '';
    };
    nameservers = [
      config.devices.gaia.ip
    ];
    hosts = {
      "::1" = [ "localhost" ];
      "127.0.0.1" = [ "localhost" ];
      # because we use hosts defined here to advertise records on the LAN,
      # forcibly do not advertise a loopback IP associated with any hostname on the LAN.
      "127.0.0.2" = lib.mkForce [ ];
    };
  };
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
    "net.ipv6.conf.all.forwarding" = "1";
  };
  services.openssh.openFirewall = false;
  services.tailscale.useRoutingFeatures = "server";
}
