{ config, ... }:
{
  services.frigate = {
    enable = true;
    hostname = "frigate";
    settings = {
      auth.enabled = false;
      mqtt = {
        enabled = true;
        host = "gaia.home.arpa";
        port = 1883;
        stats_interval = 30;
      };
      cameras.arges = {
        ffmpeg.inputs = [{
          path = "rtsp://127.0.0.1:8554/arges";
          input_args = "preset-rtsp-restream";
          roles = [ "audio" "detect" "record" ];
        }];
      };
    };
  };

  services.go2rtc = {
    enable = true;
    settings = {
      rtsp.listen = ":8554";
      webrtc.listen = ":8555";
      streams = {
        arges = "rtsp://frigate:\${ARGES_RTSP_PASSWORD}@arges.home.arpa/media/video1";
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
    onlySSL = true;
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

  systemd.services.go2rtc = {
    serviceConfig.EnvironmentFile = config.sops.secrets.go2rtc-secrets.path;
  };
  sops.secrets.go2rtc-secrets = {
    sopsFile = ./secrets.yaml;
  };

  environment.persistence."/persist".directories = [{
    directory = "/var/lib/frigate";
    mode = "750";
    user = "frigate";
    group = "frigate";
  }];
}
