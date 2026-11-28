{
  flake.modules.nixos."hosts/hyperion" = { config, ... }:
    {
      virtualisation.arion.projects.torrent.settings = {
        services.caesura.service = {
          image = "ghcr.io/rogueoneecho/caesura:latest";
          # same as qbittorrent
          user = "1000:1000";
          networks = [ "internal" ];
          labels = { "com.centurylinklabs.watchtower.enable" = "true"; };
          volumes = [
            "/var/lib/caesura/cache:/cache"
            "/torrents:/srv/shared:shared"
            "${config.sops.secrets.caesura-config.path}:/config.yml"
          ];

          # hardening
          security_opt = [ "no-new-privileges:true" ];
          capabilities.ALL = false;
        };
      };

      sops.secrets.caesura-config = {
        sopsFile = ../../secrets.yaml;
        uid = 1000;
        gid = 1000;
      };

      environment.persistence."/persist".directories = [ "/var/lib/caesura" ];
    };
}
