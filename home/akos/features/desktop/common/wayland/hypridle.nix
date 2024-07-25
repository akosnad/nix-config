{ config, lib, pkgs, ... }:
let
  hyprlock = "${config.programs.hyprlock.package}/bin/hyprlock";
  pgrep = "${pkgs.procps}/bin/pgrep";
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  pkill = "${pkgs.procps}/bin/pkill";

  isLocked = "${pgrep} -x hyprlock";

  # TODO: make this configurable
  lockTime = 60 * 5;

  gracePeriod = config.programs.hyprlock.settings.general.grace;
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
        lock_cmd = hyprlock;
        unlock_cmd = "${pkill} --signal SIGUSR1 hyprlock";
        ignore_dbus_inhibit = false;
      };
      listener =
        # lock screen
        [{
          timeout = graceTime;
          on-timeout = hyprlock;
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
