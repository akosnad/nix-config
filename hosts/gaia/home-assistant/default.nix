{ config, pkgs, ... }:
{
  imports = [
    ./postgres.nix
    ./lovelace
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
    ];
    config = {
      homeassistant = {
        name = "Gaia";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = "!secret elevation";
        unit_system = "metric";
        time_zone = "Europe/Budapest";
      };
      frontend = {
        themes = "!include_dir_merge_named themes";
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
