{
  config.flake.modules.nixos."hosts/hyperion" =
    { config, ... }:
    {
      services.lidarr = {
        enable = true;
        dataDir = "/var/lib/lidarr";
        settings = {
          server.urlbase = "/lidarr";
        };
      };

      services.nginx.virtualHosts."${config.networking.hostName}".locations = {
        "/lidarr".proxyPass =
          "http://127.0.0.1:${toString config.services.lidarr.settings.server.port}$request_uri";
      };

      environment.persistence = {
        "/persist".directories = [
          {
            directory = config.services.lidarr.dataDir;
            inherit (config.services.lidarr) user group;
            mode = "u=rwx,g=rx,o=";
          }
        ];
      };

      services.restic.backups.persist.exclude =
        map (x: "/persist${config.services.lidarr.dataDir}/${x}")
          [
            "MediaCover"
            "logs"
            "Backups"
          ];
    };
}
