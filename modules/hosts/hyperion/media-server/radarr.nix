{
  config.flake.modules.nixos."hosts/hyperion" =
    { config, ... }:
    {
      services.radarr = {
        enable = true;
        dataDir = "/var/lib/radarr";
        settings = {
          server.urlbase = "/radarr";
        };
      };

      services.nginx.virtualHosts."${config.networking.hostName}".locations = {
        "/radarr".proxyPass =
          "http://127.0.0.1:${toString config.services.radarr.settings.server.port}$request_uri";
      };

      environment.persistence = {
        "/persist".directories = [
          {
            directory = config.services.radarr.dataDir;
            inherit (config.services.radarr) user group;
            mode = "u=rwx,g=rx,o=";
          }
        ];
      };

      services.restic.backups.persist-onedrive.exclude =
        map (x: "/persist${config.services.radarr.dataDir}/${x}")
          [
            "MediaCover"
            "logs"
            "Backups"
          ];
    };
}
