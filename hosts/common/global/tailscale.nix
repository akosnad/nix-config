{ lib, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = lib.mkDefault "client";
    authKeyFile = "/run/secrets-for-users/tailscale-auth-key";
  };

  sops.secrets.tailscale-auth-key = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };

  networking.firewall.allowedUDPPorts = [ 41641 ];

  environment.persistence = {
    "/persist".directories = [ "/var/lib/tailscale" ];
  };
}
