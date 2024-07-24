{ config, lib, pkgs, ... }:
let
  swaylock = "${config.programs.swaylock.package}/bin/swaylock";
  pgrep = "${pkgs.procps}/bin/pgrep";
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";

  isLocked = "${pgrep} -x ${swaylock}";

  # TODO: make this configurable
  lockTime = 60 * 15;

  afterLockTimeout =
    { timeout
    , command
    , resumeCommand ? null
    ,
    }: [
      {
        timeout = lockTime + timeout;
        inherit command resumeCommand;
      }
      {
        command = "${isLocked} && ${command}";
        inherit resumeCommand timeout;
      }
    ];
in
{
  services.swayidle = {
    enable = true;
    systemdTarget = "graphical-session.target";
    timeouts =
      # lock screen
      [{
        timeout = lockTime;
        command = "${swaylock} --daemonize";
      }]
      ++
      # mute mic
      (afterLockTimeout {
        timeout = 10;
        command = "${wpctl} set-mute @DEFAULT_SOURCE@ 1";
        resumeCommand = "${wpctl} set-mute @DEFAULT_SOURCE@ 0";
      })
      ++
      # turn off displays (hyprland)
      (lib.optionals config.wayland.windowManager.hyprland.enable (afterLockTimeout {
        timeout = 30;
        command = "${hyprctl} dispatch dpms off";
        resumeCommand = "${hyprctl} dispatch dpms on";
      }))
    ;
  };
}
