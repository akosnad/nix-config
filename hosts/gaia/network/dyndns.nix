{ config, ... }:
{
  services.cloudflare-dyndns = {
    enable = true;
    domains = [ "gaia.fzt.one" ];
    ipv6 = true;
    apiTokenFile = config.sops.secrets.cloudflare-dyndns-token.path;
  };

  sops.secrets.cloudflare-dyndns-token = {
    sopsFile = ../secrets.yaml;
  };
}
