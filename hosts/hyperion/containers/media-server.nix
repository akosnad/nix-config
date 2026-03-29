{ lib, config, ... }:
let
  commonServiceOptions = {
    restart = "unless-stopped";
    networks = [ "internal" "torrent_internal" ];
    labels = { "com.centurylinklabs.watchtower.enable" = "true"; };
    environment = {
      TZ = "Europe/Budapest";
      PUID = "1000";
      PGID = "1000";
    };
  };
in
{
  virtualisation.arion.projects.media-server.settings = {
    services = {
      radarr.service = lib.recursiveUpdate commonServiceOptions {
        image = "lscr.io/linuxserver/radarr:latest";
        container_name = "radarr";
        volumes = [
          "/var/lib/radarr:/config"
          "/media/Radarr/:/raid/Radarr"
          "/torrents/Radarr/:/raid/Torrents/Radarr"
        ];
        blkio_config.weight = 800;
        ports = [ "7878:7878" ];
      };

      sonarr.service = lib.recursiveUpdate commonServiceOptions {
        image = "lscr.io/linuxserver/sonarr:latest";
        container_name = "sonarr";
        volumes = [
          "/var/lib/sonarr:/config"
          "/media/Sonarr/:/raid/Sonarr"
          "/torrents/Sonarr/:/raid/Torrents/Sonarr"
        ];
        blkio_config.weight = 800;
        ports = [ "8989:8989" ];
      };
    };

    networks = {
      internal.driver = "bridge";
      torrent_internal.external = true;
    };
  };

  systemd.services.arion-media-server = {
    after = [ "arion-torrent.service" ];
    wants = [ "arion-torrent.service" ];
    requires = [ "arion-torrent.service" ];
  };

  services.nginx.virtualHosts."${config.networking.hostName}".locations = {
    "/radarr".proxyPass = "http://127.0.0.1:7878$request_uri";
    "/sonarr".proxyPass = "http://127.0.0.1:8989$request_uri";
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/radarr"
      "/var/lib/sonarr"
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [
      # radarr HTTP
      7878
      # sonarr HTTP
      8989
    ];
  };
}
