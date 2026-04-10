{ lib, ... }:
{
  flake.modules.nixos.postgres =
    { config, ... }:
    {
      services.postgresql = {
        enable = true;
        settings = {
          max_connections = "300";
          shared_buffers = "80MB";
        };
      };
      environment.persistence."/persist".directories = [
        {
          directory = config.services.postgresql.dataDir;
          mode = "750";
          user = config.systemd.services.postgresql.serviceConfig.User;
          group = config.systemd.services.postgresql.serviceConfig.Group;
        }
      ];
      services.restic.backups = {
        persist = lib.mkIf config.environment.persistence."/persist".enable {
          exclude = [
            config.services.postgresql.dataDir
            "/persist${config.services.postgresql.dataDir}"
            "/persist/var/lib/postgresql"
            config.services.postgresqlBackup.location
          ];
        };
        postgres = {
          initialize = true;
          repository = "rclone:backup:/${config.networking.hostName}/postgres";
          passwordFile = config.sops.secrets.restic-postgres-password.path;
          rcloneConfigFile = "${
            lib.optionalString config.environment.persistence."/persist".enable "/persist"
          }/etc/rclone.conf";
          pruneOpts = [
            "--keep-daily 14"
            "--keep-weekly 9"
          ];
          timerConfig = {
            OnCalendar = "*-*-* 06:10:00";
          };
          paths = [ "${config.services.postgresqlBackup.location}" ];
        };
      };

      services.postgresqlBackup = {
        enable = true;
        startAt = "*-*-* 01:15:00";
        compression = "none"; # TODO: gzip --rsyncable possible?
        location = "${
          lib.optionalString config.environment.persistence."/persist".enable "/persist"
        }/var/backup/postgresql";
      };

      sops.secrets.restic-postgres-password = { };
    };
}
