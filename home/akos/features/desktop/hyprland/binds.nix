{ pkgs, config, ... }:
let
  inherit (pkgs) writeShellScript;
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";

  exit = writeShellScript "exit.sh" ''
    systemctl --user stop hyprland-session.service
    ${hyprctl} dispatch exit
  '';

  wofi-launch = writeShellScript "wofi-launch.sh" ''
    # if wofi is running, close it
    if [ $(pgrep wofi) ]; then
        kill $(pidof wofi)
    # if not running, launch it
    else
        exec wofi --show drun,run
    fi
  '';

  # unit defined in ./wallpaper.nix
  cycle-wallpaper = writeShellScript "cycle-wallpaper" ''
    systemctl --user --wait start wallpaper-changer.service
  '';

  toggle-dark-mode = "toggle-theme"; # defined in global/default.nix

  toggle-gammastep = writeShellScript "toggle-gammastep.sh" ''
    state="$(systemctl is-active --user gammastep)"

    # if gammastep service is running, stop it

    if [[ "$state" == "deactivating" ]]; then
        exit 0
    fi

    if [[ "$state" == "active" ]]; then
        notify-send -t 3000 -e 'Gammastep' 'Gammastep is now disabled'
        systemctl --user stop gammastep
    # if not running, start it
    else
        systemctl --user start gammastep
        notify-send -t 3000 -e 'Gammastep' 'Gammastep is now enabled'
    fi
  '';
in
{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    "$browser" = "firefox";

    bind = [
      "$mainMod, Return, exec, alacritty"
      "$mainMod, Q, exec, $browser"
      "$mainMod, ESCAPE, killactive,"
      "$mainMod, M, exec, ${exit}"
      "$mainMod, E, exec, nautilus"
      "$mainMod, F, togglefloating"
      ", Menu, exec, ${wofi-launch}"
      "ALT, Space, exec, ${wofi-launch}"
      "$mainMod, Backspace, exec, ${toggle-dark-mode}"
      "$mainMod, N, exec, swaync-client -t"
      "$mainMod, G, exec, ${toggle-gammastep}"
      "$mainMod, L, exec, ${config.programs.swaylock.package}/bin/swaylock -f --grace 0 --fade-in 1"
      "$mainMod, W, exec, ${cycle-wallpaper}"
      "SUPERALT, L, exec, systemctl suspend"

      "$mainMod, Space, togglesplit, # dwindle"

      # Move focus with mainMod + arrow keys
      "$mainMod, left, movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up, movefocus, u"
      "$mainMod, down, movefocus, d"

      # Switch workspaces with mainMod + [0-9]
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod, 0, workspace, 10"

      "SUPERCTRL, left, workspace, m-1"
      "SUPERCTRL, right, workspace, m+1"

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"
      "$mainMod SHIFT, 6, movetoworkspace, 6"
      "$mainMod SHIFT, 7, movetoworkspace, 7"
      "$mainMod SHIFT, 8, movetoworkspace, 8"
      "$mainMod SHIFT, 9, movetoworkspace, 9"
      "$mainMod SHIFT, 0, movetoworkspace, 10"

      "$mainMod SHIFT, left, movetoworkspace, -1"
      "$mainMod SHIFT, right, movetoworkspace, +1"

      # move current workspace between monitors
      "SUPERALT, left, movecurrentworkspacetomonitor, -1"
      "SUPERALT, right, movecurrentworkspacetomonitor, +1"

      # "$mainMod, S, exec, systemctl suspend"
      # "$mainMod, P, pseudo, # dwindle"

      # Scroll through existing workspaces with mainMod + scroll
      "$mainMod, mouse_down, workspace, e+1"
      "$mainMod, mouse_up, workspace, e-1"

      ",Print, exec, ${pkgs.grimblast}/bin/grimblast --notify copy"
      "ALT, Print, exec, ${pkgs.grimblast}/bin/grimblast --notify copy active"
      "$mainMod, Print, exec, ${pkgs.grimblast}/bin/grimblast --notify copy area"
    ];

    bindle = [
      ",XF86MonBrightnessUp, exec, ${pkgs.light}/bin/light -A 5"
      ",XF86MonBrightnessDown, exec, ${pkgs.light}/bin/light -U 5"

      ",XF86AudioRaiseVolume, exec, ${pkgs.alsa-utils}/bin/amixer -q set Master 5%+"
      ",XF86AudioLowerVolume, exec, ${pkgs.alsa-utils}/bin/amixer -q set Master 5%-"
      ",XF86AudioMute, exec, ${pkgs.alsa-utils}/bin/amixer -q set Master toggle"
      ",XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
      ",XF86AudioPause, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
    ];

    bindm = [
      # Move/resize windows with mainMod + LMB/RMB and dragging
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    bindr = [
      "SUPER, SUPER_L, hyprexpo:expo, toggle"
    ];
  };
}
