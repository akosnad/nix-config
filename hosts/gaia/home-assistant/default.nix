{ config, pkgs, ... }:
{
  imports = [
    ./postgres.nix
    ./lovelace
    ./zones.nix
    ./automations
  ];

  environment.systemPackages = with pkgs; [
    home-assistant-cli
  ];

  services.home-assistant = {
    enable = true;
    openFirewall = false;
    extraComponents = [
      "default_config"
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
    ];
    extraPackages = python3Packages: with python3Packages; [
      # recorder postgresql support
      psycopg2
    ];
    customComponents = with pkgs.home-assistant-custom-components; [
      xiaomi_miot
      localtuya
    ];
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      mushroom
      mini-media-player
      plotly-graph-card
      wallpanel
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
    };
  };

  sops.secrets.home-assistant-secrets = {
    owner = config.systemd.services.home-assistant.serviceConfig.User;
    sopsFile = ./secrets.yaml;
    path = "/var/lib/hass/secrets.yaml";
    restartUnits = [ "home-assistant.service" ];
  };
}
