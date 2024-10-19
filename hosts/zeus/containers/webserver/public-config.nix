{ pkgs, ... }: pkgs.writeText "public-config.conf" /* conf */ ''
  server {
      resolver 127.0.0.11 valid=1s;

      listen 80 default_server;
      listen [::]:80 default_server;

      server_name repo.fzt.one;
      root /serve;

      location / {
          autoindex on;
      }

      location /webarchive {
          auth_basic "";
          auth_basic_user_file "/etc/nginx/passwd";
          autoindex on;

          add_header Cache-Control "public, max-age=31536000, must-revalidate";
          location ~ /$ {
              add_header Cache-Control "no-cache";
          }
      }

      location /torrents {
          auth_basic "";
          auth_basic_user_file "/etc/nginx/passwd-torrents";
          #auth_basic off;
          autoindex on;

          add_header Cache-Control "public, max-age=31536000, must-revalidate";
          location ~ /$ {
              add_header Cache-Control "no-cache";
          }
      }
  }
''
