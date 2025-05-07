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
      ] ++ (withPrefix "/persist/var/lib" [
        "systemd/coredump"

        "tailscale/tailscaled.log*.txt"
      ]);
    };
  };

  sops.secrets.restic-persist-password = {
    sopsFile = ./secrets.yaml;
  };
}
