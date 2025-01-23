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
          "/raid/dvdrips/:/raid/dvdrips"
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

  services.nginx.virtualHosts.zeus.locations = {
    "/radarr".proxyPass = "http://127.0.0.1:7878$request_uri";
    "/sonarr".proxyPass = "http://127.0.0.1:8989$request_uri";
    "^~ /overseerr" = {
      extraConfig = /* nginx */ ''
        set $app 'overseerr';

        # Remove /overseerr path to pass to the app
        rewrite ^/overseerr/?(.*)$ /$1 break;
        proxy_pass http://127.0.0.1:5055; # NO TRAILING SLASH

        # Redirect location headers
        proxy_redirect ^ /$app;
        proxy_redirect /setup /$app/setup;
        proxy_redirect /login /$app/login;

        # Sub filters to replace hardcoded paths
        proxy_set_header Accept-Encoding "";
        sub_filter_once off;
        sub_filter_types *;
        sub_filter 'href="/"' 'href="/$app"';
        sub_filter 'href="/login"' 'href="/$app/login"';
        sub_filter 'href:"/"' 'href:"/$app"';
        sub_filter '\/_next' '\/$app\/_next';
        sub_filter '/_next' '/$app/_next';
        sub_filter '/api/v1' '/$app/api/v1';
        sub_filter '/login/plex/loading' '/$app/login/plex/loading';
        sub_filter '/images/' '/$app/images/';
        sub_filter '/android-' '/$app/android-';
        sub_filter '/apple-' '/$app/apple-';
        sub_filter '/favicon' '/$app/favicon';
        sub_filter '/logo_' '/$app/logo_';
        sub_filter '/site.webmanifest' '/$app/site.webmanifest';
      '';
    };
    "/plex".return = "301 http://zeus:32400/web/";
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/overseerr"
      "/var/lib/radarr"
      "/var/lib/sonarr"
      "/var/lib/plex"
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [
      # overseerr HTTP
      5055
      # radarr HTTP
      7878
      # sonarr HTTP
      8989
      # plex
      # reference: https://support.plex.tv/articles/201543147-what-network-ports-do-i-need-to-allow-through-my-firewall/
      32400
      8324
      32469
    ];
    allowedUDPPorts = [
      # plex
      32400
      5353
      32410
      32412
      32413
      32414
    ];
  };

  sops.secrets.plex-env = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };
}
