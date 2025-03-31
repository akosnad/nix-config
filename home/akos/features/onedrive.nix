{ pkgs, lib, config, ... }:
let
  impermanenceEnabled = builtins.hasAttr "/persist/${config.home.homeDirectory}" config.home.persistence;

  remote = "onedrive-personal";
  mountpoint = "${config.home.homeDirectory}/OneDrive";

  rcloneConfigFile = if impermanenceEnabled then "/persist/${config.home.homeDirectory}/.config/rclone/rclone.conf" else "/${config.home.homeDirectory}/.config/rclone/rclone.conf";

  cacheDirPrefix =
    if impermanenceEnabled
    then "/persist/${config.home.homeDirectory}"
    else "/${config.home.homeDirectory}";
  cacheDir = "${cacheDirPrefix}/.cache/rclone-onedrive-personal";
in
{
  systemd.user.services.rclone-onedrive-personal = {
    Unit = {
      Description = "Rclone Onedrive Personal mount";
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "notify";
      ExecStartPre = /* bash */ ''
        ${lib.getExe' pkgs.coreutils "mkdir"} -m 700 -p "${mountpoint}"
      '';
      ExecStart = /* bash */ ''
        ${lib.getExe pkgs.rclone} mount -v \
          --config "${rcloneConfigFile}" \
          --cache-dir "${cacheDir}"\
          --dir-cache-time 15m \
          --vfs-cache-mode full \
          --vfs-cache-max-age 168h \
          --allow-non-empty \
          --use-mmap=true \
          --vfs-cache-max-size 200G \
          --no-modtime \
          --rc \
          ${remote}: "${mountpoint}"
      '';
      ExecStop = /* bash */ ''
        ${lib.getExe' pkgs.fuse "fusermount"} -uz "${config.home.homeDirectory}/OneDrive"
      '';
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  home.persistence."/persist/${config.home.homeDirectory}" = {
    files = [ ".config/rclone/rclone.conf" ];
  };
}
