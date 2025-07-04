{ config, ... }:
let
  withPrefix = prefix: paths: map (path: "${prefix}/${path}") paths;
in
{
  services.restic.backups = {
    persist-onedrive = {
      initialize = true;
      repository = "rclone:onedrive-personal:/Backups/${config.networking.hostName}-persist";
      passwordFile = config.sops.secrets.restic-persist-password.path;
      rcloneConfigFile = "/persist/etc/rclone.conf";
      pruneOpts = [ "--keep-daily 14" "--keep-weekly 9" ];
      timerConfig = {
        OnCalendar = "*-*-* 23:30:00";
      };

      paths = [ "/persist" ];
      exclude = [
        "/persist/var/log"

        # backed up separately
        "${config.services.postgresqlBackup.location}"
      ] ++ (withPrefix "/persist/var/lib" [
        # backed up separately
        "postgresql"

        "systemd/coredump"

        "tailscale/tailscaled.log*.txt"
      ]);
    };

    postgres = {
      initialize = true;
      repository = "rclone:onedrive-personal:/Backups/${config.networking.hostName}-postgres";
      passwordFile = config.sops.secrets.restic-postgres-password.path;
      rcloneConfigFile = "/persist/etc/rclone.conf";
      pruneOpts = [ "--keep-daily 14" "--keep-weekly 9" ];
      timerConfig = {
        OnCalendar = "*-*-* 06:10:00";
      };
      paths = [ "${config.services.postgresqlBackup.location}" ];
    };
  };

  sops.secrets.restic-persist-password = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets.restic-postgres-password = {
    sopsFile = ./secrets.yaml;
  };

  services.postgresqlBackup = {
    enable = true;
    startAt = "*-*-* 01:15:00";
    databases = [ "matrix-synapse" "miniflux" ];
    compression = "none"; # TODO: gzip --rsyncable possible?
    location = "/persist/var/backup/postgresql";
  };
}
