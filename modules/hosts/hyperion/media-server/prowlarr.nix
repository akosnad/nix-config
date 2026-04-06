{
  config.flake.modules.nixos."hosts/hyperion" =
    { config, ... }:
    {
      services.prowlarr = {
        enable = true;
        dataDir = "/var/lib/prowlarr";
        settings = {
          server.urlbase = "/prowlarr";
        };
      };

      services.nginx.virtualHosts."${config.networking.hostName}".locations = {
        "/prowlarr".proxyPass =
          "http://127.0.0.1:${toString config.services.prowlarr.settings.server.port}$request_uri";
      };

      environment.persistence = {
        "/persist".directories = [
          {
            directory = "/var/lib/private/prowlarr";
            mode = "u=rwx,g=rx,o=";
          }
        ];
      };

      services.restic.backups.persist-onedrive.exclude =
        map (x: "/persist/var/lib/private/prowlarr/${x}")
          [
            "logs"
            "Backups"
          ];
    };
}
