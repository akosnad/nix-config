{ lib, ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = lib.mkDefault "client";
    authKeyFile = "/run/secrets-for-users/tailscale-auth-key";
    extraUpFlags = [
      "--login-server"
      "https://ts.fzt.one"
    ];
  };

  sops.secrets.tailscale-auth-key = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/tailscale" ];
  };
}
