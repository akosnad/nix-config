{
  flake.modules.nixos."hosts/hyperion" = { config, ... }: {
    services.dawarich = {
      enable = true;
      localDomain = "timeline.home.arpa";
      webPort = 3205;
      configureNginx = true;
      secretKeyBaseFile = config.sops.secrets.dawarich-secret-key-base.path;
    };

    services.nginx.virtualHosts.${config.services.dawarich.localDomain} = {
      forceSSL = true;
      enableACME = true;
    };

    sops.secrets.dawarich-secret-key-base = {
      sopsFile = ./secrets.yaml;
      owner = config.services.dawarich.user;
      inherit (config.services.dawarich) group;
    };

    environment.persistence = {
      "/persist".directories = [{
        directory = "/var/cache/dawarich";
        inherit (config.services.dawarich) user group;
        mode = "u=rwx,g=rx,o=";
      }];
    };

    services.restic.backups.persist.exclude = [
      "/var/cache/dawarich"
    ];
  };
}
