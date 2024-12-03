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
      "bluetooth"
    ];
    extraPackages = python3Packages: with python3Packages; [
      # recorder postgresql support
      psycopg2

      # also needed for xiaomi_miot
      # TODO: upstream?
      hap-python
    ];
    customComponents = with pkgs.home-assistant-custom-components; [
      xiaomi_miot
      localtuya
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
        ];
      };
      http = {
        ip_ban_enabled = false;
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.0/8" "::1" "10.20.0.0/24" ];
      };
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

  networking.hosts = {
    "::1" = [ "homeassistant" "homeassistant.${config.networking.domain}" ];
    "127.0.0.1" = [ "homeassistant" "homeassistant.${config.networking.domain}" ];
  };
  services.nginx.virtualHosts.homeassistant = {
    forceSSL = true;
    enableACME = true;
    serverAliases = [ "homeassistant.home.arpa" ];
    listenAddresses = [
      # loopback
      "[::1]"
      "127.0.0.1"
      "127.0.0.2"

      # lan
      "10.20.0.1"

      # tailscale
      "100.98.172.43"
    ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:8123/";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-For $remote_addr;
      '';
    };
  };
}
