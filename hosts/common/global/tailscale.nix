{ lib, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = lib.mkDefault "client";
    authKeyFile = "/run/secrets/tailscale-auth-key";
  };

  sops.secrets.tailscale-auth-key = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };

  networking.firewall.allowedUDPPorts = [ 41641 ];

  networking.hosts = {
    "10.20.0.4" = [ "zeus" "zeus.local" ];
  };
}
