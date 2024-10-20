{ lib, pkgs, ... }:
let
  commonServiceOptions = {
    networks = [ "internal" ];
    labels = { "com.centurylinklabs.watchtower.enable" = "true"; };
    environment = {
      TZ = "Europe/Budapest";
    };
  };
in
{

  # TODO: ratio manager, start-stop scripts

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
          "/var/lib/qbittorrent/:/config"
          "torrents:/raid/Torrents"
        ];
        ports = [
          "15577:15577"
          "15577:15577/udp"
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
        volumes = [ "/var/lib/jackett/:/config" ];
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
        docker volume create --driver=local --opt=type=none --opt=o=bind --opt=device=/raid/Torrents torrents
      '';
    });
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/qbittorrent"
      "/var/lib/jackett"
    ];
  };
}
