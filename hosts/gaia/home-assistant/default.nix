{ config, pkgs, ... }:
{
  imports = [
    ./postgres.nix
    ./lovelace
    ./zones.nix
    ./automations
    ./scripts
    ./scenes
    ./hvac.nix
    ./heating.nix
    ./template-entities
    ./notify.nix
    ./bkk-stop.nix
    ./network-entities.nix
  ];

  environment.systemPackages = with pkgs; [
    home-assistant-cli
  ];

  services.home-assistant = {
    enable = true;
    openFirewall = false;
    extraComponents = [
      "default_config"
      "cloud"
      "met"
      "esphome"
      "google_translate"
      "shopping_list"
      "radio_browser"
      "recorder"
      "yeelight"
      "co2signal"
      "adguard"
      "tuya"
      "androidtv_remote"
      "plex"
      "openai_conversation"
      "spotify"
      "google"
      "cast"
      "dlna_dmr"
      "history"
      "logbook"
      "rest"
      "rest_command"
      "camera"
      "stream"
      "generic"
      "onvif"
      "ipp"
      "tplink"
    ];
    extraPackages = python3Packages: with python3Packages; [
      # recorder postgresql support
      psycopg2
    ];
    customComponents = with pkgs.home-assistant-custom-components; [
      xiaomi_miot
      localtuya
      hass-node-red
    ];
    customThemes = with pkgs.home-assistant-custom-themes; [
      google
      soft
    ];
    config = {
      homeassistant = {
        name = "Gaia";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = "!secret elevation";
        unit_system = "metric";
        time_zone = "Europe/Budapest";
        auth_providers = [
          { type = "homeassistant"; }
          {
            type = "trusted_networks";
            trusted_networks = [
              "127.0.0.0/8"
              "10.20.0.0/16"
            ];
          }
        ];
      };
      http = { };
      backup = { };
      mobile_app = { };
      config = { };
      system_health = { };
      system_log = { };
      history = { };
      logbook = { };
      cloud = { };
      stream = { };
    };
  };

  sops.secrets.home-assistant-secrets = {
    owner = config.systemd.services.home-assistant.serviceConfig.User;
    sopsFile = ./secrets.yaml;
    path = "/var/lib/hass/secrets.yaml";
    restartUnits = [ "home-assistant.service" ];
  };
}
