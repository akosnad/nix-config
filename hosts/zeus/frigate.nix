{ config, ... }:
{
  services.frigate = {
    enable = true;
    hostname = "frigate";
    settings = {
      auth.enabled = false;
      cameras.arges = {
        ffmpeg.inputs = [{
          # FIXME: use a secret
          path = "rtsp://frigate:{FRIGATE_RTSP_PASSWORD}@arges.home.arpa/media/video1";
          roles = [ "audio" "detect" "record" ];
        }];
      };
    };
  };

  services.nginx.virtualHosts.frigate = {
    serverAliases = [ "frigate.home.arpa" ];
    forceSSL = true;
    enableACME = true;
  };

  systemd.services.frigate = {
    serviceConfig.EnvironmentFile = config.sops.secrets.frigate-secrets.path;
  };

  environment.persistence."/persist".directories = [{
    directory = "/var/lib/frigate";
    mode = "750";
    user = "frigate";
    group = "frigate";
  }];

  sops.secrets.frigate-secrets = {
    sopsFile = ./secrets.yaml;
    owner = "frigate";
    group = "frigate";
  };
}
