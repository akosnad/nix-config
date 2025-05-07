{ config, ... }:
let
  baseDomain = "fzt.one";
  stunServerPort = 3478;
in
{
  services.headscale = {
    enable = true;
    settings = {
      server_url = "https://ts.${baseDomain}";
      policy.mode = "file";
      ephemeral_node_inactivity_timeout = "5m";
      database.type = "sqlite";
      dns = {
        magic_dns = true;
        base_domain = "tailnet.${baseDomain}";
        nameservers = {
          global = [
            "1.1.1.1"
            "1.0.0.1"
            "2606:4700:4700::1111"
            "2606:4700:4700::1001"
          ];
          split = {
            "home.arpa" = [ config.devices.gaia.ip ];
          };
        };
        search_domains = [ "home.arpa" ];
      };
      derp.server = {
        enabled = true;
        region_code = "fzt";
        region_name = "ts.${baseDomain} Embedded DERP";
        stun_listen_addr = "0.0.0.0:${toString stunServerPort}";
      };
    };
    policy = {
      tagOwners = {
        "tag:installer" = [ "akos" ];
        "tag:trusted" = [ "akos" ];
      };
      acls = [
        { action = "accept"; src = [ "*" ]; dst = [ "tag:installer:*" ]; }
        { action = "accept"; src = [ "tag:trusted" ]; dst = [ "*:*" ]; }
      ];
    };
  };

  networking.hosts."127.0.0.1" = [ "ts.${baseDomain}" ];
  networking.firewall.allowedUDPPorts = [ stunServerPort ];

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
