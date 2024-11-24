{ config, ... }:
{
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        port = 1883;
        omitPasswordAuth = true;
        acl = [ "topic readwrite #" ];
        settings = {
          protocol = "mqtt";
          allow_anonymous = true;
        };
      }
      {
        port = 8883;
        omitPasswordAuth = true;
        acl = [ "pattern readwrite #" ];
        settings = {
          protocol = "mqtt";
          require_certificate = true;
          use_identity_as_username = true;
          cafile = config.sops.secrets.mosquitto-cafile.path;
          certfile = config.sops.secrets.mosquitto-certfile.path;
          keyfile = config.sops.secrets.mosquitto-keyfile.path;
        };
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 8883 ];

  sops.secrets.mosquitto-cafile = {
    sopsFile = ./secrets.yaml;
    owner = config.systemd.services.mosquitto.serviceConfig.User;
  };
  sops.secrets.mosquitto-certfile = {
    sopsFile = ./secrets.yaml;
    owner = config.systemd.services.mosquitto.serviceConfig.User;
  };
  sops.secrets.mosquitto-keyfile = {
    sopsFile = ./secrets.yaml;
    owner = config.systemd.services.mosquitto.serviceConfig.User;
  };
}
