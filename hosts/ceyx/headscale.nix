{ config, ... }:
let
  baseDomain = "fzt.one";
in
{
  services.headscale = {
    enable = true;
    settings = {
      server_url = "https://ts.${baseDomain}";
      policy = {
        mode = "file";
        path = null; # TODO
      };
      ephemeral_node_inactivity_timeout = "5m";
      dns.base_domain = "tailnet.${baseDomain}";
      database.type = "sqlite";
    };
  };

  services.nginx.virtualHosts."ts.${baseDomain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${config.services.headscale.address}:${toString config.services.headscale.port}";
      proxyWebsockets = true;
    };
  };

  environment.persistence."/persist".directories = [{
    directory = "/var/lib/headscale";
    mode = "750";
    inherit (config.services.headscale) user group;
  }];
}
