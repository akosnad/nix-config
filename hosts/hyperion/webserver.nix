{ config, ... }:
{
  services.nginx = {
    enable = true;
    virtualHosts = {
      "${config.networking.hostName}" = {
        serverAliases = [ "${config.networking.hostName}.${config.networking.domain}" ];
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
