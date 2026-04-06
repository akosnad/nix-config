{ lib, ... }:
{
  config.flake.modules.nixos."hosts/hyperion" = { pkgs, config, ... }:
    let
      qbittorrentConfigPath = "/var/lib/qbittorrent";
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
        src = ./_qbt-manager;
        cargoLock = {
          lockFile = ./_qbt-manager/Cargo.lock;
          outputHashes = {
            "qbit-rs-0.4.6" = "sha256-h5/FRMStRHr2diOXJSSd689ogSYq1O5dDoHk8v5eQ0g=";
          };
        };
        doCheck = false;

        meta.mainProgram = pname;
      };

      qbt-manager-config = (pkgs.formats.yaml { }).generate "qbt-manager-config.yaml" (import ./_config.nix);
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
              # 'shared' allows the container to see
              # sub-datasets in ZFS pool under the folder
              # reference: https://docs.docker.com/engine/storage/bind-mounts/#options-for---volume
              "/torrents:/raid/Torrents:shared"
            ];
            ports = [
              "15577:15577"
              "15577:15577/udp"
              "8818:8080"
            ];
            blkio_config.weight = 1000;
          };
        };

        networks.internal.driver = "bridge";
      };

      services.nginx.virtualHosts."${config.networking.hostName}".locations = {
        "/torrents/".extraConfig = /* nginx */ ''
          rewrite /torrents/(.*) /$1  break;
          proxy_pass http://127.0.0.1:8818;
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
        ];
        allowedUDPPorts = [
          # qbittorrent
          15577
        ];
      };
    };
}
