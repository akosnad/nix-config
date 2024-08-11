{
  services.cloudflare-dyndns = {
    enable = true;
    domains = [ "gaia.fzt.one" ];
    ipv6 = true;
    apiTokenFile = "/run/secrets-for-users/cloudflare-dyndns-token";
  };

  sops.secrets.cloudflare-dyndns-token = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };
}
