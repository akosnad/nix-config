{ config, ... }:
let
  withPrefix = prefix: paths: map (path: "${prefix}/${path}") paths;
in
{
  services.restic.backups = {
    persist-onedrive = {
      initialize = true;
      repository = "rclone:onedrive-personal:/Backups/zeus-persist";
      passwordFile = config.sops.secrets.restic-persist-password.path;
      rcloneConfigFile = "/persist/etc/rclone.conf";
      pruneOpts = [ "--keep-daily 14" "--keep-weekly 9" ];
      timerConfig = {
        OnCalendar = "*-*-* 23:30:00";
      };

      paths = [ "/persist" ];
      exclude = [
        "/persist/var/log"
      ] ++ (withPrefix "/persist/var/lib" [
        "radarr/MediaCover"
        "sonarr/MediaCover"
        "radarr/logs"
        "sonarr/logs"
        "overseerr/logs"
        "radarr/Backups"
        "sonarr/Backups"

        "jackett/Jackett/log*"
        "jackett/Jackett/updater.txt.*"

        "docker"

        # backed up separately
        "postgresql"

        "systemd/coredump"

        "tailscale/tailscaled.log*.txt"

        "private/esphome/.platformio"
        "private/esphome/.esphome/build"

        "qbittorrent/qBittorrent/logs"

        "frigate/.cache"
        "frigate/exports"
        "frigate/recordings"
        "frigate/clips"
      ]) ++ (withPrefix "/persist/var/lib/plex/Library/Application Support/Plex Media Server" [
        "Logs"
        "Cache"
        "Media"
        "Metadata"
      ]);
    };
  };

  sops.secrets.restic-persist-password = {
    sopsFile = ./secrets.yaml;
  };
}
