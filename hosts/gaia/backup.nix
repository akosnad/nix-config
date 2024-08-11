{ pkgs, lib, config, ... }:
let
  restic-hass-password = config.sops.secrets.restic-hass-password.path;
  hass-token = config.sops.secrets.hass-token.path;
  backupPrepareScript = pkgs.writeShellApplication {
    name = "backup-prepare";
    runtimeInputs = [ pkgs.home-assistant-cli ];
    text = ''
      export HASS_SERVER=http://localhost:8123
      # shellcheck source=/dev/null
      source "${hass-token}"
      hass-cli service call backup.create
    '';
  };
in
{
  services.restic.backups = {
    home-assistant = {
      paths = [ "${config.services.home-assistant.configDir}/backups" ];
      initialize = true;
      repository = "rclone:onedrive-personal:/Backups/gaia-home-assistant";
      passwordFile = restic-hass-password;
      rcloneConfigFile = "/etc/rclone.conf";
      backupPrepareCommand = "${lib.getExe backupPrepareScript}";
      pruneOpts = [ "--keep-last 14" ];
      timerConfig = {
        OnCalendar = "*-*-* 23:00:00";
      };
    };
  };

  sops.secrets.restic-hass-password = {
    sopsFile = ./secrets.yaml;
    neededForUsers = true;
  };
  sops.secrets.hass-token = {
    sopsFile = ./secrets.yaml;
    neededForUsers = true;
  };
}
