{ config, ... }:
{
  services.sonarr = {
    enable = true;
    dataDir = "/var/lib/sonarr";
    settings = {
      server.urlbase = "/sonarr";
    };
  };

  services.nginx.virtualHosts."${config.networking.hostName}".locations = {
    "/sonarr".proxyPass = "http://127.0.0.1:${toString config.services.sonarr.settings.server.port}$request_uri";
  };

  environment.persistence = {
    "/persist".directories = [{
      directory = config.services.sonarr.dataDir;
      inherit (config.services.sonarr) user group;
      mode = "u=rwx,g=rx,o=";
    }];
  };

  services.restic.backups.persist-onedrive.exclude = map (x: "/persist${config.services.sonarr.dataDir}/${x}") [
    "MediaCover"
    "logs"
    "Backups"
  ];
}
