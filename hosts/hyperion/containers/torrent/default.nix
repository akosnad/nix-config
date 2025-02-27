{ lib, pkgs, config, ... }:
let
  torrentsPath = "/raid/Torrents";
  qbittorrentConfigPath = "/var/lib/qbittorrent";
  jackettConfigPath = "/var/lib/jackett";
  commonServiceOptions = {
    restart = "unless-stopped";
    networks = [ "internal" ];
    labels = { "com.centurylinklabs.watchtower.enable" = "true"; };
    environment = {
      TZ = "Europe/Budapest";
    };
  };

  qbt-manager = pkgs.rustPlatform.buildRustPackage rec {
    pname = "qbt-manager";
    version = "0.1.0";
    src = ./qbt-manager;
    cargoLock = {
      lockFile = ./qbt-manager/Cargo.lock;
      outputHashes = {
        "qbit-rs-0.4.6" = "sha256-h5/FRMStRHr2diOXJSSd689ogSYq1O5dDoHk8v5eQ0g=";
      };
    };
    doCheck = false;

    meta.mainProgram = pname;
  };

  qbt-manager-config = (pkgs.formats.yaml { }).generate "qbt-manager-config.yaml" (import ./config.nix);
in
{
  virtualisation.arion.projects.torrent.settings = {
    services = {
      qbittorrent.service = lib.recursiveUpdate commonServiceOptions {
        image = "lscr.io/linuxserver/qbittorrent:latest";
        container_name = "qbittorrent";
        environment = {
          PUID = "1000";
          PGID = "1000";
          WEBUI_PORT = "8080";
        };
        volumes = [
          "${qbittorrentConfigPath}/:/config"
          "torrents:${torrentsPath}"
        ];
        ports = [
          "15577:15577"
          "15577:15577/udp"
          "8818:8080"
        ];
        blkio_config.weight = 1000;
      };

      jackett.service = lib.recursiveUpdate commonServiceOptions {
        image = "lscr.io/linuxserver/jackett:latest";
        container_name = "jackett";
        environment = {
          PUID = "1000";
          PGID = "1000";
        };
        volumes = [ "${jackettConfigPath}/:/config" ];
        ports = [ "9117:9117" ];
      };
    };

    networks.internal.driver = "bridge";
    docker-compose.volumes.torrents.external = true;
  };

  systemd.services.arion-torrent = {
    serviceConfig.ExecStartPre = lib.getExe (pkgs.writeShellApplication {
      name = "arion-torrents-prestart";
      runtimeInputs = with pkgs; [ docker-client ];
      text = ''
        docker volume create --driver=local --opt=type=none --opt=o=bind --opt=device=${torrentsPath} torrents
      '';
    });
  };

  services.nginx.virtualHosts."${config.networking.hostName}".locations = {
    "/torrents/".extraConfig = /* nginx */ ''
      rewrite /torrents/(.*) /$1  break;
      proxy_pass http://127.0.0.1:8818;
    '';
    "/jackett".proxyPass = "http://127.0.0.1:9117$request_uri";
    "/bitmagnet".extraConfig = /* nginx */ ''
      rewrite /bitmagnet/(.*) http://${config.networking.hostName}:3333/$1 redirect;
      rewrite /bitmagnet http://${config.networking.hostName}:3333/ redirect;
    '';
  };

  systemd.services.qbt-manager =
    let
      parentService = config.systemd.services.arion-torrent.name;
    in
    {
      wantedBy = [ "multi-user.target" ];
      wants = [ parentService ];
      after = [ "network.target" parentService ];
      partOf = [ parentService ];
      serviceConfig = {
        Restart = "always";
        RestartSec = "5";
        ExecStart = lib.getExe qbt-manager;
        EnvironmentFile = config.sops.secrets.qbittorrent-password.path;
      };
      environment = {
        RUST_LOG = "info";
        QBITTORRENT_USERNAME = "admin";
        QBITTORRENT_URL = "http://127.0.0.1:8818/";
        QBT_MANAGER_CONFIG = qbt-manager-config;
        MQTT_HOST = "gaia.${config.networking.domain}";
      };
    };

  environment.persistence = {
    "/persist".directories = [
      qbittorrentConfigPath
      jackettConfigPath
    ];
  };

  sops.secrets.qbittorrent-password = {
    sopsFile = ../../secrets.yaml;
    neededForUsers = true;
  };

  networking.firewall = {
    allowedTCPPorts = [
      # qbittorrent
      8818
      15577
      # jackett
      9117
      # bitmagnet
      3333
      3334
    ];
    allowedUDPPorts = [
      # qbittorrent
      15577
      # bitmagnet
      3334
    ];
  };
}
