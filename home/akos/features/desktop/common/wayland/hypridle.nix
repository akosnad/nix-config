{ config, lib, pkgs, ... }:
let
  swaylock = "${config.programs.swaylock.package}/bin/swaylock";
  pgrep = "${pkgs.procps}/bin/pgrep";
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  pkill = "${pkgs.procps}/bin/pkill";

  isLocked = "${pgrep} -x swaylock";

  # TODO: make this configurable
  lockTime = 60 * 5;
  gracePeriod = 5;
  graceTime = lockTime - gracePeriod;

  afterLockTimeout =
    { timeout
    , on-timeout
    , on-resume ? null
    ,
    }: [
      {
        timeout = lockTime + timeout;
        inherit on-timeout on-resume;
      }
      {
        on-timeout = "${isLocked} && ${on-timeout}";
        inherit on-resume timeout;
      }
    ];
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${swaylock} --daemonize";
        unlock_cmd = "${pkill} --signal SIGUSR1 swaylock";
        ignore_dbus_inhibit = false;
      };
      listener =
        # lock screen
        [{
          timeout = lockTime;
          on-timeout = "${swaylock} --daemonize";
        }]
        # notify before locking
        ++
        [{
          timeout = graceTime;
          on-timeout = "${notify-send} -e -t ${builtins.toString (gracePeriod * 1000)} \"Session\" \"Screen will lock soon due to inactivity...\"";
        }]
        # mute mic
        ++
        (afterLockTimeout {
          timeout = 10;
          on-timeout = "${wpctl} set-mute @DEFAULT_SOURCE@ 1";
          on-resume = "${wpctl} set-mute @DEFAULT_SOURCE@ 0";
        })
        # turn off displays (hyprland)
        ++
        (lib.optionals config.wayland.windowManager.hyprland.enable (afterLockTimeout {
          timeout = 30;
          on-timeout = "${hyprctl} dispatch dpms off";
          on-resume = "${hyprctl} dispatch dpms on";
        }))
      ;
    };
  };
}
