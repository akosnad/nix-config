{ config, ... }:
{
  services.pocket-id = {
    enable = true;
    settings = {
      HOST = "127.0.0.1";
      PORT = 1411;
      TRUST_PROXY = true;
      APP_URL = "https://auth.${config.networking.domain}";
      ANALYTICS_DISABLED = true;
      UI_CONFIG_DISABLED = true;
      APP_NAME = config.networking.domain;
      ALLOW_USER_SIGNUPS = "withToken";
    };
    environmentFile = config.sops.secrets.pocket-id-env.path;
  };

  sops.secrets.pocket-id-env = {
    sopsFile = ./secrets.yaml;
    owner = config.services.pocket-id.user;
    inherit (config.services.pocket-id) group;
  };

  services.nginx.virtualHosts."auth.${config.networking.domain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${config.services.pocket-id.settings.HOST}:${toString config.services.pocket-id.settings.PORT}";
      # this also ensures that the IP -> GeoLiteDB resolving is correct
      recommendedProxySettings = true;
    };
    extraConfig = ''
      # increased header sizes due to frontend specialities
      # reference: https://pocket-id.org/docs/advanced/nginx-reverse-proxy
      proxy_busy_buffers_size   512k;
      proxy_buffers   4 512k;
      proxy_buffer_size   256k;
    '';
  };

  environment.persistence."/persist".directories = [{
    directory = config.services.pocket-id.dataDir;
    mode = "750";
    inherit (config.services.pocket-id) user group;
  }];
}
