{
  flake.modules.nixos.obelisk = { config, ... }: {
    services.obelisk = {
      enable = true;
      webui.port = 5006;
    };

    services.nginx.virtualHosts."workflows.home.arpa" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          proxyPass = "http://${config.services.obelisk.serverConfig.webui.listening_addr}";
        };
        "/api".extraConfig = ''
          rewrite /api/(.*) /$1  break;
          proxy_pass http://${config.services.obelisk.serverConfig.api.listening_addr};
        '';
      };
    };

    environment.persistence = {
      "/persist".directories = [
        {
          directory = config.services.obelisk.dataDir;
          user = "obelisk";
          group = "obelisk";
          mode = "u=rwx,g=rx,o=";
        }
        {
          directory = config.services.obelisk.cacheDir;
          user = "obelisk";
          group = "obelisk";
          mode = "u=rwx,g=rx,o=";
        }
      ];
    };

    services.restic.backups.persist.exclude = [ config.services.obelisk.cacheDir ];
  };
}
