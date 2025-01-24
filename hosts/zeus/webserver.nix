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

      # mirror public site to LAN
      "repo.fzt.one" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/webarchive" = {
            extraConfig = /* nginx */ ''
              rewrite ^/webarchive/(.*) /$1 break;
              autoindex on;
            '';
            root = "/raid/akos/Backup/webarchive";
          };
          "/torrents" = {
            extraConfig = /* nginx */ ''
              rewrite ^/torrents/(.*) /$1 break;
              autoindex on;
            '';
            root = "/raid/Torrents";
          };
          "/pub" = {
            extraConfig = /* nginx */ ''
              rewrite ^/pub/(.*) /$1 break;
              autoindex on;
            '';
            root = "/raid/internet-public";
          };
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
