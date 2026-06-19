{ lib, config, ... }:
let
  flakeConfig = config;
in
{
  config.flake.modules.nixos."hosts/hyperion" = { config, pkgs, ... }:
    let
      inherit (config.networking) domain;

      ffmpegCuda = pkgs.ffmpeg_6-headless.override {
        withCudaLLVM = true;
        withNvdec = true;
        withNvenc = true;
      };
    in
    {
      services.frigate = {
        enable = true;
        hostname = "frigate";
        vaapiDriver = "nvidia";
        settings = rec {
          auth.enabled = false;
          proxy.default_role = "admin";
          mqtt = {
            enabled = true;
            host = "gaia.${domain}";
            port = 1883;
            stats_interval = 30;
          };
          ffmpeg = {
            path = ffmpegCuda;
            hwaccel_args = "preset-nvidia";
          };
          cameras = {
            arges = {
              ffmpeg = {
                input_args = "preset-rtsp-restream";
                output_args.record = "preset-record-generic-audio-aac";
                inputs = [
                  {
                    path = "rtsp://127.0.0.1:8554/arges";
                    roles = [ "record" "audio" ];
                  }
                  {
                    path = "rtsp://127.0.0.1:8554/arges_sub";
                    roles = [ "detect" ];
                  }
                ];
              };
              live.streams.main_stream = "arges";
              zones = {
                inside-gate = {
                  coordinates = "0.188,0.44,0.953,0.61,1,0.818,1,1,0,1,0,0.638";
                  inertia = 3;
                  loitering_time = 0;
                };
              };
              review.alerts = {
                required_zones = [ "inside-gate" ];
                labels = [ "person" "car" ];
              };
              motion = {
                threshold = 40;
                contour_area = 30;
                mask = [
                  # right side tree
                  "0.573,0,0.593,0.216,0.795,0.27,0.919,0.4,1,0.446,1,0"
                  # left side bush
                  "0.291,0,0.227,0.072,0.258,0.178,0.153,0.338,0,0.504,0,0"
                  # neighbours' area
                  "0.158,0.158,0.818,0.26,0.701,0,0.224,0"
                ];
              };
            };
            brontes = {
              ffmpeg = {
                input_args = "preset-rtsp-restream";
                output_args.record = "preset-record-generic-audio-aac";
                inputs = [
                  {
                    path = "rtsp://127.0.0.1:8554/brontes";
                    roles = [ "record" "audio" ];
                  }
                  {
                    path = "rtsp://127.0.0.1:8554/brontes_sub";
                    roles = [ "detect" ];
                  }
                ];
              };
              live.streams.main_stream = "brontes";
              zones = {
                back-garden = {
                  coordinates = "0,1,0,0.753,0.339,0.165,0.697,0.194,1,0.535,1,1";
                  inertia = 3;
                  loitering_time = 0;
                };
                pavilon = {
                  coordinates = "0.442,0.196,0.574,0.2,0.576,0.118,0.444,0.114";
                  inertia = 3;
                  loitering_time = 0;
                };
                bird-feeder = {
                  coordinates = "0.042,0.509,0.092,0.513,0.122,0.468,0.12,0.387,0.038,0.385,0.013,0.46";
                  inertia = 3;
                  loitering_time = 0;
                };
              };
              review.alerts = {
                required_zones = [ "back-garden" ];
                labels = [ "person" ];
              };
              motion = {
                threshold = 40;
                contour_area = 30;
                mask = [
                  # left side bushes
                  "0,0.368,0.301,0.124,0.301,0,0,0"
                  # back bush
                  "0.294,0.074,0.73,0.084,0.787,0,0.286,0"
                  # right side bush
                  "0.729,0.084,1,0.289,1,0,0.757,0"
                ];
              };
            };
          };
          detect = {
            enabled = true;
            fps = 5;
          };
          objects.track = [
            "person"
            "car"
            "dog"
            "cat"
            "bird"
          ];
          detectors.openvino = {
            type = "openvino";
            device = "GPU";
            inherit model;
          };
          model = {
            model_type = "yolo-generic";
            width = 320;
            height = 320;
            input_tensor = "nchw";
            input_dtype = "float";
            input_pixel_format = "rgb";
            path = "${pkgs.fetchFromGitHub {
               owner = "negoti8za";
               repo = "frigate-yolo";
               rev = "b42a1a23d735547d0fb12e2bd95dc0444e24cbe2";
               hash = "sha256-lHu0sTSpsEjFcaeERKAO1tmDfh28aZUAv5XyueAZaro=";
            }}/yolov9_s_320_frigate_intel.onnx";
            labelmap_path = ./coco-80.txt;
          };
          record = {
            enabled = true;
            expire_interval = 120;
            retain.days = 30;
            alerts.retain = {
              days = 180;
              mode = "all";
            };
            detections.retain = {
              days = 180;
              mode = "all";
            };
          };
          snapshots = {
            enabled = true;
            timestamp = true;
            bounding_box = true;
            retain.default = 365;
            quality = 60;
          };
          audio = {
            enabled = true;
            max_not_heard = 90;
            min_volume = 700;
            listen = [
              "bark"
              "fire_alarm"
              "scream"
              "yell"
            ];
          };

          # just to make frigate happy; make it enable webrtc restreaming.
          #
          # we use an external go2rtc service, but frigate assumes
          # it controls go2rtc to be able to do webrtc.
          go2rtc = config.services.go2rtc.settings;
        };
      };

      services.go2rtc = {
        enable = true;
        settings = {
          ffmpeg.bin = lib.getExe ffmpegCuda;
          rtsp.listen = ":8554";
          webrtc.candidates = [
            # loopback
            "127.0.0.1:8555"
            # lan
            "${flakeConfig.flake.devices."${config.networking.hostName}".ip}:8555"
            # tailscale
            "100.64.0.3:8555"
            "[fd7a:115c:a1e0::3]:8555"
          ];
          streams = {
            arges = [ "ffmpeg:rtsp://frigate:\${ARGES_RTSP_PASSWORD}@arges.${domain}/media/video1#video=copy#audio=opus#audio=aac#hardware" ];
            arges_sub = [ "ffmpeg:rtsp://frigate:\${ARGES_RTSP_PASSWORD}@arges.${domain}/media/video_sub#video=copy#audio=opus#audio=aac#hardware" ];
            brontes = [ "ffmpeg:rtsp://frigate:\${BRONTES_RTSP_PASSWORD}@brontes.${domain}/media/video1#video=copy#audio=opus#audio=aac#hardware" ];
            brontes_sub = [ "ffmpeg:rtsp://frigate:\${BRONTES_RTSP_PASSWORD}@brontes.${domain}/media/video_sub#video=copy#audio=opus#audio=aac#hardware" ];
          };
        };
      };

      services.nginx.virtualHosts.frigate = {
        serverAliases = [ "frigate.${domain}" ];
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
          # also listen on default port 5000
          {
            addr = "0.0.0.0";
            port = 5000;
            ssl = false;
          }
          {
            addr = "[::]";
            port = 5000;
            ssl = false;
          }
        ];
      };

      systemd.services.go2rtc = {
        serviceConfig = {
          EnvironmentFile = config.sops.secrets.go2rtc-secrets.path;
          Restart = "always";
          RestartSec = "5s";
          TimeoutStopSec = "5s";
        };
      };
      sops.secrets.go2rtc-secrets = {
        sopsFile = ../secrets.yaml;
      };

      systemd.services.frigate = {
        requires = [ "zfs.target" ];
        after = [ "zfs.target" ];
      };

      networking.firewall = {
        allowedTCPPorts = [
          # http, https
          80
          443
          # frigate api http
          5000
          # go2rtc api, rtsp, webrtc, stun
          1984
          8554
          8555
          3478
        ];
        allowedUDPPorts = [
          # go2rtc rtsp, webrtc, stun
          8554
          8555
          3478
        ];
      };
    };
}
