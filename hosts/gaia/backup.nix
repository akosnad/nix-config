{ pkgs, lib, config, ... }:
let
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
    home-assistant-data = {
      paths = [ "${config.services.home-assistant.configDir}/backups" ];
      initialize = true;
      repository = "rclone:onedrive-personal:/Backups/gaia-home-assistant";
      passwordFile = config.sops.secrets.restic-hass-password.path;
      rcloneConfigFile = "/etc/rclone.conf";
      backupPrepareCommand = "${lib.getExe backupPrepareScript}";
      pruneOpts = [ "--keep-daily 14" "--keep-weekly 9" ];
      timerConfig = {
        OnCalendar = "*-*-* 23:00:00";
      };
    };
    gaia-persist = {
      paths = [
        "/var/lib/tailscale"
        "/var/lib/systemd"
        "/var/lib/private/step-ca"
        "/var/lib/dnsmasq"
        "/var/lib/nixos"
        "/var/lib/mosquitto/mosquitto.db"

        "/etc/ssh/ssh_host_*_key"
        "/etc/ssh/ssh_host_*_key.pub"
        "/etc/rclone.conf"
        "/etc/machine-id"
      ];
      exclude = [
        "/var/lib/tailscale/tailscaled.log*.txt"
        "/var/lib/systemd/coredump"
      ];
      initialize = true;
      repository = "rclone:onedrive-personal:/Backups/gaia-persist";
      passwordFile = config.sops.secrets.restic-gaia-persist-password.path;
      rcloneConfigFile = "/etc/rclone.conf";
      pruneOpts = [ "--keep-daily 14" "--keep-weekly 9" ];
      timerConfig = {
        OnCalendar = "*-*-* 00:10:00";
      };
    };
  };

  sops.secrets =
    let
      secretsCommonOpts = {
        sopsFile = ./secrets.yaml;
      };
      mkSecrets = names: lib.genAttrs names (_: secretsCommonOpts);
    in
    mkSecrets [
      "restic-hass-password"
      "restic-gaia-persist-password"
      "hass-token"
    ];
}
