{ lib, config, ... }:
let
  commonServiceOptions = {
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
      overseerr.service = lib.recursiveUpdate commonServiceOptions {
        image = "sctx/overseerr:latest";
        container_name = "overseerr";
        networks = lib.mkForce [ "internal" ];
        environment = {
          LOG_LEVEL = "debug";
        };
        volumes = [
          "/var/lib/overseerr:/app/config"
        ];
        ports = [ "5055:5055" ];
      };

      radarr.service = lib.recursiveUpdate commonServiceOptions {
        image = "lscr.io/linuxserver/radarr:latest";
        container_name = "radarr";
        volumes = [
          "/var/lib/radarr:/config"
          "/raid/Radarr/:/raid/Radarr"
          "/raid/Torrents/Radarr/:/raid/Torrents/Radarr"
        ];
        blkio_config.weight = 800;
        ports = [ "7878:7878" ];
      };

      sonarr.service = lib.recursiveUpdate commonServiceOptions {
        image = "lscr.io/linuxserver/sonarr:latest";
        container_name = "sonarr";
        volumes = [
          "/var/lib/sonarr:/config"
          "/raid/Sonarr/:/raid/Sonarr"
          "/raid/Torrents/Sonarr/:/raid/Torrents/Sonarr"
        ];
        blkio_config.weight = 800;
        ports = [ "8989:8989" ];
      };

      plex.service = lib.recursiveUpdate commonServiceOptions {
        image = "lscr.io/linuxserver/plex:latest";
        container_name = "plex";
        networks = lib.mkForce [ ];
        network_mode = "host";
        environment = {
          VERSION = "docker";
        };
        env_file = [ config.sops.secrets.plex-env.path ];
        volumes = [
          "/var/lib/plex:/config"
          "/raid/Eloadasok/:/raid/Eloadasok"
          "/raid/Lidarr/:/raid/Lidarr"
          "/raid/Music/:/raid/Music"
          "/raid/Radarr/:/raid/Radarr"
          "/raid/Sonarr/:/raid/Sonarr"
          "/raid/mediaklikk/:/raid/mediaklikk"
          "/raid/Torrents/nCoreFilmek/:/raid/Torrents/nCoreFilmek"
          "/raid/Torrents/nCoreSorozatok/:/raid/Torrents/nCoreSorozatok"
        ];
        blkio_config.weight = 30;
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

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/overseerr"
      "/var/lib/radarr"
      "/var/lib/sonarr"
      "/var/lib/plex"
    ];
  };

  sops.secrets.plex-env = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };
}
