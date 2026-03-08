{ lib, config, ... }:
let
  mkNginxReverseProxy = name: port: {
    # TV doesn't allow installing CA certs,
    # so we resort back to HTTP...
    forceSSL = false;
    onlySSL = true;
    enableACME = true;
    listen = [
      {
        addr = "0.0.0.0";
        port = 80;
        ssl = false;
      }
      {
        addr = "0.0.0.0";
        port = 443;
        ssl = true;
      }
      {
        addr = "[::]";
        port = 80;
        ssl = false;
      }
      {
        addr = "[::]";
        port = 443;
        ssl = true;
      }
    ];
    serverAliases = [ "${name}.${config.networking.domain}" ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
in
{
  services.jellyfin = {
    enable = true;
  };

  services.jellyseerr = {
    enable = true;
    port = 5056;
    configDir = "/var/lib/private/jellyseerr";
  };

  services.nginx.virtualHosts = lib.mapAttrs mkNginxReverseProxy {
    media = 8096;
    jellyseerr = config.services.jellyseerr.port;
  };

  environment.persistence."/persist".directories = [
    {
      directory = config.services.jellyfin.dataDir;
      inherit (config.services.jellyfin) user;
      inherit (config.services.jellyfin) group;
      mode = "u=rwx,g=rx,o=";
    }
    config.services.jellyseerr.configDir
  ];

  services.restic.backups.persist-onedrive.exclude = [
    "/persist/${config.services.jellyfin.logDir}"
    "/persist/${config.services.jellyseerr.configDir}"
  ];
}
