{ lib, ... }:
let
  withPrefix = prefix: paths: map (path: "${prefix}/${path}") paths;
in
{
  flake.modules.nixos.base =
    { config, ... }:
    {
      config = lib.mkIf config.environment.persistence."/persist".enable {
        services.restic.backups = {
          persist = {
            initialize = true;
            repository = "rclone:backup:/${config.networking.hostName}/persist";
            passwordFile = config.sops.secrets.restic-persist-password.path;
            rcloneConfigFile = "/persist/etc/rclone.conf";
            pruneOpts = [
              "--keep-daily 14"
              "--keep-weekly 9"
            ];
            timerConfig = {
              OnCalendar = "*-*-* 23:30:00";
            };

            paths = [ "/persist" ];
            exclude = [
              "/persist/var/log"
              "/persist/opt/"
            ]
            ++ (withPrefix "/persist/var/lib" [
              "docker"
              "systemd/coredump"
              "tailscale/tailscaled.log*.txt"
            ])
            ++ (withPrefix "/persist/home/*" [
              ".cache"
              "Downloads"
              "src"
            ]);
          };
        };

        sops.secrets.restic-persist-password = { };
        sops.secrets.backup-ssh-key = { };
      };
    };
}
