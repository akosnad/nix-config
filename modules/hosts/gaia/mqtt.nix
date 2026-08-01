{ lib, ... }:
{
  config.flake.modules.nixos."hosts/gaia" = { config, ... }:
    let
      mkMosquittoSecret = {
        sopsFile = ./secrets.yaml;
        owner = config.systemd.services.mosquitto.serviceConfig.User;
      };
      mkMosquittoSecrets = names:
        lib.genAttrs (map (name: "mosquitto-${name}") names) (_name: mkMosquittoSecret);

      tls = {
        protocol = "mqtt";
        allow_anonymous = false;
        require_certificate = true;
        use_identity_as_username = true;
        cafile = config.sops.secrets.mosquitto-cafile.path;
        certfile = config.sops.secrets.mosquitto-certfile.path;
        keyfile = config.sops.secrets.mosquitto-keyfile.path;
      };
    in
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
            acl = [
              # disallow creating zones in home assistant
              "pattern deny owntracks/+/+/waypoints"
              "pattern deny owntracks/+/+/waypoint"

              "pattern readwrite #"
            ];
            settings = tls;
          }
          {
            port = 8884;
            omitPasswordAuth = true;
            acl = [ "pattern readwrite tracker/#" ];
            settings = tls // {
              cafile = config.sops.secrets.mosquitto-cafile-alt.path;
              certfile = config.sops.secrets.mosquitto-certfile-alt.path;
              keyfile = config.sops.secrets.mosquitto-keyfile-alt.path;
            };
          }
          {
            port = 8084;
            omitPasswordAuth = true;
            acl = [ "pattern readwrite #" ];
            settings = {
              protocol = "websockets";
              allow_anonymous = true;
            };
          }
        ];
      };

      networking.firewall.allowedTCPPorts = [ 8883 8884 ];

      sops.secrets = mkMosquittoSecrets [
        "cafile"
        "certfile"
        "keyfile"
        "cafile-alt"
        "certfile-alt"
        "keyfile-alt"
      ];
    };
}
