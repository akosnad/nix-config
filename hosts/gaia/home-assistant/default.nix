{ config, pkgs, ... }:
let
  publicMediaMountPath = "${config.services.home-assistant.configDir}/www/public/media";
in
{
  imports = [
    ./postgres.nix
    ./lovelace
    ./automations
    ./scripts
    ./scenes
    ./hvac.nix
    ./heating.nix
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
      "androidtv"
      "nfandroidtv"
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
      "bluetooth_adapters"
      "bluetooth_tracker"
      "bluetooth_le_tracker"
      "bthome"
      "ibeacon"
      "voip"
      "fully_kiosk"
      "wake_word"
      "wyoming"
      "xiaomi_ble"
      "html5"
      "my"
      "lg_thinq"

      # calendar related
      "local_calendar"
      "remote_calendar"
      "holiday"
    ];
    extraPackages = python3Packages: with python3Packages; [
      # recorder postgresql support
      psycopg2

      # also needed for xiaomi_miot
      # TODO: upstream?
      hap-python
    ];
    customComponents = with pkgs.home-assistant-custom-components; [
      localtuya
      frigate
      webrtc-camera
      adaptive_lighting
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
        allowlist_external_dirs = [ "/tmp" ];
        media_dirs.local = "/tmp";
      };
      http = {
        ip_ban_enabled = false;
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.0/8" "::1" "10.0.0.0/8" ];
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
      media_source = { };
      adaptive_lighting = { };
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
    serverAliases = [ "homeassistant.${config.networking.domain}" ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:8123/";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-For $remote_addr;
      '';
    };
    locations."/api/notify.html5/callback".extraConfig = ''
      if ($http_authorization = "") { return 403; }
      allow all;
      proxy_pass http://127.0.0.1:8123;
      proxy_set_header Host $host;
      proxy_set_header Authorization $http_authorization;
      proxy_pass_header Authorization;
      proxy_redirect http:// https://;
    '';
  };
  systemd.services.home-assistant = {
    serviceConfig = {
      TemporaryFilesystem = [ publicMediaMountPath ];
    };
  };
  systemd.tmpfiles.rules = [
    # ensure public media mount can be mounted and be accessed by HASS
    "d ${publicMediaMountPath} 0755 hass hass -"
  ];
}
