{ pkgs, ... }: pkgs.writeText "lan-webserver.conf" /* conf */ ''
  # needed for grafana
  map $http_upgrade $connection_upgrade {
      default upgrade;
      ${"''"} close;
  }

  server {
      resolver 127.0.0.11 valid=1s;

      set $radarr "radarr.media-server_internal";
      set $sonarr "sonarr.media-server_internal";
      set $overseerr "overseerr.media-server_internal";
      set $jackett "jackett.torrent_internal";
      set $qbittorrent "qbittorrent-web.torrent_internal";
      set $grafana "grafana.monitoring_internal";

      listen 443 default_server ssl http2;
      listen [::]:443 default_server ssl http2;
      listen 80;
      listen [::]:80;

      server_name zeus;

      ssl_certificate /ca/zeus.crt;
      ssl_certificate_key /ca/zeus.key;

      disable_symlinks off;
      root /srv/http;
      autoindex on;

      location / {
          index index.php index.html;
      }

      location ~ \.php$ {
          include fastcgi_params;
          fastcgi_pass lan-php:9000;
          fastcgi_index index.php;
          fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;
      }

      location /radarr {
          proxy_pass http://$radarr:7878$request_uri;
      }

      location /sonarr {
          proxy_pass http://$sonarr:8989$request_uri;
      }

      location ^~ /overseerr {
          set $app 'overseerr';

  # Remove /overseerr path to pass to the app
          rewrite ^/overseerr/?(.*)$ /$1 break;
          proxy_pass http://$overseerr:5055; # NO TRAILING SLASH

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
      }

      location /plex {
          return 301 http://zeus:32400/web/;
      }

      location /torrents/ {
          #return 301 https://zeus:8080/;
          rewrite /torrents/(.*) /$1  break;
          proxy_pass http://$qbittorrent;
      }

      location /jackett {
          proxy_pass http://$jackett:9117$request_uri;
      }

      location /nzb {
          return 301 http://zeus:6789/;
      }

      location /esphome {
          rewrite /esphome/(.*) /$1 break;
          proxy_pass http://zeus:6052;
      }

      location /grafana {
          #rewrite /foo(/.*|$) /$1  break;
          #proxy_redirect off;

          proxy_pass http://$grafana/;
          proxy_set_header Host $http_host;
      }

      location /grafana/api/live/ {
          #rewrite /foo(/.*|$) /$1  break;
          #proxy_redirect off;

          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
          proxy_set_header Host $http_host;
          proxy_pass http://$grafana/;
      }
  }

  # public mirror
  server {
      resolver 127.0.0.11 valid=1s;

      listen 443 ssl http2;
      listen [::]:443 ssl http2;
      listen 80;
      listen [::]:80;

      ssl_certificate /ca/repo.crt;
      ssl_certificate_key /ca/repo.key;

      server_name repo.fzt.one;
      root /serve;

      location / {
          autoindex on;
      }

      location /webarchive {
          auth_basic off;
          autoindex on;

          add_header Cache-Control "public, max-age=31536000, must-revalidate";
          location ~ /$ {
              add_header Cache-Control "no-cache";
          }
      }

      location /torrents {
          auth_basic off;
          autoindex on;

          add_header Cache-Control "public, max-age=31536000, must-revalidate";
          location ~ /$ {
              add_header Cache-Control "no-cache";
          }
      }
  }
''
