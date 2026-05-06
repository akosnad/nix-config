{
  flake.modules.nixos."hosts/hyperion" = { config, ... }: {
    services.dawarich = {
      enable = true;
      localDomain = "timeline.home.arpa";
      webPort = 3205;
      configureNginx = true;
      secretKeyBaseFile = config.sops.secrets.dawarich-secret-key-base.path;
      environment = {
        NOMINATIM_API_HOST = "nominatim.home.arpa";
      };
    };

    services.nginx.virtualHosts.${config.services.dawarich.localDomain} = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        client_max_body_size 2G;
      '';
    };

    sops.secrets.dawarich-secret-key-base = {
      sopsFile = ./secrets.yaml;
      owner = config.services.dawarich.user;
      inherit (config.services.dawarich) group;
    };

    environment.persistence = {
      "/persist".directories = [
        {
          directory = "/var/cache/dawarich";
          inherit (config.services.dawarich) user group;
          mode = "u=rwx,g=rx,o=";
        }
        {
          directory = "/var/lib/dawarich";
          inherit (config.services.dawarich) user group;
          mode = "u=rwx,g=rx,o=";
        }
        {
          directory = "/var/lib/redis-dawarich";
          user = "redis-dawarich";
          group = "redis-dawarich";
          mode = "u=rwx,g=,o=";
        }
      ];
    };

    services.restic.backups.persist.exclude = [
      "/var/cache/dawarich"
    ];
    services.postgresqlBackup.databases = [ config.services.dawarich.database.name ];
  };
}
