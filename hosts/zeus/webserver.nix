{ config, ... }:
{
  services.nginx = {
    enable = true;
    virtualHosts = {
      zeus = {
        serverAliases = [ "zeus.${config.networking.domain}" ];
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/srv/";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
