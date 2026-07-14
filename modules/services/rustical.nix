{
  flake.modules.nixos.dav = { config, ... }: {
    services.rustical = {
      enable = true;
      environmentFiles = [ config.sops.secrets.rustical-env.path ];
      settings = {
        oidc = {
          name = "fzt.one";
          issuer = "https://auth.fzt.one";
          client_id = "\${CLIENT_ID}";
          client_secret = "\${CLIENT_SECRET}";
          claim_userid = "preferred_username";
          scopes = [ "openid" "profile" "groups" ];
          require_group = "dav";
          allow_sign_up = true;
        };
        frontend.allow_password_login = false;
      };
    };

    sops.secrets.rustical-env = {
      sopsFile = ../hosts/uranus/secrets.yaml;
    };

    environment.persistence."/persist".directories = [{
      directory = "/var/lib/private/rustical";
      mode = "u=rwx,g=,o=";
    }];

    services.nginx.virtualHosts."dav.fzt.one" = {
      forceSSL = true;
      enableACME = true;
      locations."/".extraConfig = /* nginx */ ''
        # allow accessing CalDav service from PWA frontends
        add_header Access-Control-Allow-Origin "*" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, PROPFIND, PROPPATCH, REPORT, OPTIONS, MKCOL, COPY, MOVE" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, Depth, Prefer, If-None-Match, If-Match" always;
        add_header Vary "Origin" always;

        if ($request_method = OPTIONS) {
          return 204;
        }

        proxy_set_header        Host $host;
        proxy_set_header        X-Real-IP $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto $scheme;
        proxy_set_header        X-Forwarded-Host $host;
        proxy_set_header        X-Forwarded-Server $hostname;
        proxy_pass http://${config.services.rustical.settings.http.host}:${toString config.services.rustical.settings.http.port};
      '';
    };
  };
}
