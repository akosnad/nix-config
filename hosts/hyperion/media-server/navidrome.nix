{ config, ... }:
{
  services.navidrome = {
    enable = true;
  };

  systemd.services.navidrome.serviceConfig = {
    BindReadOnlyPaths = [
      "/media/Lidarr"
      "/media/Music"
    ];
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/navidrome";
      inherit (config.services.navidrome) user group;
      mode = "u=rwx,g=rx,o=";
    }
  ];

  services.nginx.virtualHosts.music = {
    forceSSL = true;
    enableACME = true;
    serverAliases = [ "music.${config.networking.domain}" ];
    locations."/" = {
      proxyPass = "http://${config.services.navidrome.settings.Address}:${toString config.services.navidrome.settings.Port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
