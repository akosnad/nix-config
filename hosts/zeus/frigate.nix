{ config, ... }:
{
  services.frigate = {
    enable = true;
    hostname = "frigate";
    settings = {
      auth.enabled = false;
      # enable restreaming
      go2rtc = { };
      cameras.arges = {
        ffmpeg.inputs = [{
          path = "rtsp://frigate:{FRIGATE_RTSP_PASSWORD}@arges.home.arpa/media/video1";
          roles = [ "audio" "detect" "record" ];
        }];
      };
    };
  };

  services.nginx.virtualHosts.frigate = {
    serverAliases = [ "frigate.home.arpa" ];
    enableACME = true;

    # TODO: can't force SSL because Home Assistant doesn't trust the CA
    # tried: https://nixos.wiki/wiki/Home_Assistant#Trust_a_private_certificate_authority
    # fails to build some python packages
    forceSSL = false;
    enableSSL = true;
    listen = [
      {
        addr = "0.0.0.0";
        port = 80;
        ssl = false;
      }
      {
        addr = "0.0.0.0";
        port = 443;
        ssl = true;
      }
      {
        addr = "[::]";
        port = 80;
        ssl = false;
      }
      {
        addr = "[::]";
        port = 443;
        ssl = true;
      }
    ];
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
