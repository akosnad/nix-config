{ lib, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = lib.mkDefault "client";
  };
  networking.firewall.allowedUDPPorts = [ 41641 ];

  networking.hosts = {
    "10.20.0.4" = [ "zeus" "zeus.local" ];
  };
}
