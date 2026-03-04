{ config, ... }:
{
  services.jellyfin = {
    enable = true;
  };

  services.nginx.virtualHosts."media" = {
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
    serverAliases = [ "media.${config.networking.domain}" ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:8096";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = config.services.jellyfin.dataDir;
      inherit (config.services.jellyfin) user;
      inherit (config.services.jellyfin) group;
      mode = "u=rwx,g=rx,o=";
    }
  ];

  services.restic.backups.persist-onedrive.exclude = [
    "/persist/${config.services.jellyfin.logDir}"
  ];
}
