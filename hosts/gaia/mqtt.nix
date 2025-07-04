{ config, lib, ... }:
let
  mkMosquittoSecret = {
    sopsFile = ./secrets.yaml;
    owner = config.systemd.services.mosquitto.serviceConfig.User;
  };
  mkMosquittoSecrets = names:
    lib.genAttrs (map (name: "mosquitto-${name}") names) (_name: mkMosquittoSecret);
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
      {
        port = 8084;
        omitPasswordAuth = true;
        acl = [ "pattern readwrite #" ];
        settings = {
          protocol = "websockets";
          allow_anonymous = true;
        };
      }
      {
        port = 30160;
        omitPasswordAuth = false;
        acl = [
          "pattern readwrite vili/#"
          "pattern readwrite homeassistant/device_tracker/vili_tracker/config"
          "pattern readwrite homeassistant/binary_sensor/vili_ignition/config"
          "pattern readwrite homeassistant/binary_sensor/vili_battery_charging/config"
          "pattern readwrite homeassistant/sensor/vili_battery_voltage/config"
          "pattern readwrite homeassistant/sensor/vili_battery_charge_current/config"
          "pattern readwrite homeassistant/sensor/vili_ext_voltage/config"
          "pattern readwrite homeassistant/sensor/vili_ext_current/config"
          "pattern readwrite homeassistant/sensor/vili_int_temperature/config"
          "pattern readwrite homeassistant/sensor/vili_satellite_count/config"
          "pattern readwrite homeassistant/button/vili_reboot/config"
        ];
        users.vili = {
          passwordFile = config.sops.secrets.mosquitto-vili-password.path;
        };
        settings = {
          protocol = "mqtt";
          allow_anonymous = false;
        };
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 8883 30160 ];

  sops.secrets = mkMosquittoSecrets [
    "cafile"
    "certfile"
    "keyfile"
    "vili-password"
  ];
}
