{ pkgs, config, lib, ... }:
let
  inherit (pkgs) writeShellScript;
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";

  secondaryMonitors = builtins.filter (m: !m.primary) config.monitors;
  hasMultipleMonitors = builtins.length config.monitors > 1;

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
        export QT_QPA_PLATFORM="wayland"
        export NIXOS_OZONE_WL="1"
        exec wofi --show drun,run
    fi
  '';

  # unit defined in ./wallpaper.nix
  cycle-wallpaper = writeShellScript "cycle-wallpaper" ''
    systemctl --user --wait start wallpaper.service
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

  toggle-secondary-monitors = writeShellScript "toggle-secondary-monitors.sh" ''
    function toggle_monitor() {
      state="$(${hyprctl} monitors -j | jq -r """.[] | select(.name == \"$1\") | .dpmsStatus""")"
      if [[ "$state" == "false" ]]; then
        action="on"
      else
        action="off"
      fi

      ${hyprctl} dispatch dpms "$action" "$1"
    }

    for monitor in ${builtins.concatStringsSep " " (builtins.map (m: m.name) secondaryMonitors)}; do
      toggle_monitor "$monitor"
    done
  '';

  comma-gui-picker = pkgs.writeShellApplication {
    name = "comma-gui-picker";
    runtimeInputs = [ pkgs.zenity ];
    text = ''
      zenity --list --title="Launch GUI app" --text="Selech which package to use:" --column="Derivation outputs"
    '';
  };

  comma-gui-progress = pkgs.writeShellApplication {
    name = "comma-gui-progress";
    runtimeInputs = with pkgs; [ zenity gawk coreutils ];
    text = ''
      fifo="$(mktemp -u)"
      mkfifo "$fifo"
      cleanup() {
        rm "$fifo"
      }
      trap cleanup EXIT

      zenity --progress --auto-close --title="Launching $1..." --pulsate --text="Preparing..." <"$fifo" &
      pid="$!"

      tee >(awk '{print "# " $0; fflush()}' >"$fifo")

      wait "$pid"
    '';
  };

  comma-gui = pkgs.writeShellApplication {
    name = "comma-gui";
    runtimeInputs = with pkgs; [ zenity coreutils comma ];
    text = ''
      target="$(zenity --entry --title="Launch GUI app" --text="Enter binary name:")"

      stdout="$(mktemp)"
      stderr="$(mktemp)"
      cleanup() {
        rm -f "$stdout" "$stderr"
      }
      trap cleanup EXIT

      ( ( (comma -P "${lib.getExe comma-gui-picker}" -x "$target" 3>&2 2>&1 1>&3) | "${lib.getExe comma-gui-progress}" "$target") 1>"$stderr" 2>"$stdout") &

      wait < <(jobs -p)

      bin="$(cat "$stdout")"
      if [[ $bin == "" ]]; then
        err="$(tail -n10 "$stderr")"
        zenity --error --title="Launch GUI app failed" --text="$err"
        exit 1
      fi

      </dev/null "$bin" &>/dev/null &
      disown
    '';
  };
in
{
  wayland.windowManager.hyprland = {
    settings = {
      "$mainMod" = "SUPER";
      "$browser" = "firefox";

      bind = [
        "$mainMod, Return, exec, kitty"
        "$mainMod, Q, exec, $browser"
        "$mainMod, ESCAPE, killactive,"
        "$mainMod SHIFT, ESCAPE, exec, ${exit}"
        "$mainMod, E, exec, nautilus"
        "$mainMod, F, togglefloating"
        ", Menu, exec, ${wofi-launch}"
        "$mainMod, Menu, exec, ${lib.getExe comma-gui}"
        "ALT, Space, exec, ${wofi-launch}"
        "$mainMod, Backspace, exec, ${toggle-dark-mode}"
        "$mainMod, N, exec, swaync-client -t"
        "$mainMod, G, exec, ${toggle-gammastep}"
        "$mainMod, D, exec, ${lib.getExe config.programs.hyprlock.package} --immediate"
        "$mainMod, W, exec, ${cycle-wallpaper}"

        "$mainMod, Space, togglesplit, # dwindle"

        # Media controls with numpad 4 5 6
        "$mainMod, code:83, exec, ${pkgs.playerctl}/bin/playerctl previous"
        "$mainMod, code:84, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        "$mainMod, code:85, exec, ${pkgs.playerctl}/bin/playerctl next"

        # Move focus with mainMod + arrow keys
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        # Move focus with mainMod + hjkl
        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "$mainMod, K, movefocus, u"
        "$mainMod, J, movefocus, d"

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
        "SUPERCTRL, H, workspace, m-1"
        "SUPERCTRL, L, workspace, m+1"

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
        "$mainMod SHIFT, H, movetoworkspace, -1"
        "$mainMod SHIFT, L, movetoworkspace, +1"

        # move current workspace between monitors
        "SUPERALT, left, movecurrentworkspacetomonitor, -1"
        "SUPERALT, right, movecurrentworkspacetomonitor, +1"
        "SUPERALT, H, movecurrentworkspacetomonitor, -1"
        "SUPERALT, L, movecurrentworkspacetomonitor, +1"

        # "$mainMod, P, pseudo, # dwindle"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        ",Print, exec, ${pkgs.grimblast}/bin/grimblast --notify copy"
        "ALT, Print, exec, ${pkgs.grimblast}/bin/grimblast --notify copy active"
        "$mainMod, Print, exec, ${pkgs.grimblast}/bin/grimblast --notify copy area"

      ] ++ (lib.optional hasMultipleMonitors "$mainMod, X, exec, ${toggle-secondary-monitors}");

      bindle = [
        ",XF86MonBrightnessUp, exec, ${pkgs.light}/bin/light -A 5"
        ",XF86MonBrightnessDown, exec, ${pkgs.light}/bin/light -U 5"

        ",XF86AudioRaiseVolume, exec, ${lib.getExe pkgs.pamixer} -i 5"
        ",XF86AudioLowerVolume, exec, ${lib.getExe pkgs.pamixer} -d 5"
        ",XF86AudioMute, exec, ${lib.getExe pkgs.pamixer} -t"
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

      bindl = [
        "SUPERALT, D, exec, systemctl suspend"
      ];
    };
    extraConfig = ''
      bind = $mainMod, M, submap, move
      submap = move

      binde = , H     , movewindow, l
      binde = , J     , movewindow, d
      binde = , K     , movewindow, u
      binde = , L     , movewindow, r
      binde = , left  , movewindow, l
      binde = , down  , movewindow, d
      binde = , up    , movewindow, u
      binde = , right , movewindow, r

      bind = , 1, movetoworkspace, 1
      bind = , 2, movetoworkspace, 2
      bind = , 3, movetoworkspace, 3
      bind = , 4, movetoworkspace, 4
      bind = , 5, movetoworkspace, 5
      bind = , 6, movetoworkspace, 6
      bind = , 7, movetoworkspace, 7
      bind = , 8, movetoworkspace, 8
      bind = , 9, movetoworkspace, 9
      bind = , 0, movetoworkspace, 10

      bind = SHIFT, left , movetoworkspace, -1
      bind = SHIFT, right, movetoworkspace, +1
      bind = SHIFT, H    , movetoworkspace, -1
      bind = SHIFT, L    , movetoworkspace, +1

      bind  = , space , togglesplit,

      bind =  , ESCAPE, submap    , reset
      submap = reset

      bind = $mainMod, R, submap, resize
      submap = resize

      binde = , H     , resizeactive, -10  0
      binde = , J     , resizeactive,  0  10
      binde = , K     , resizeactive,  0 -10
      binde = , L     , resizeactive,  10  0
      binde = , left  , resizeactive, -10  0
      binde = , down  , resizeactive,  0  10
      binde = , up    , resizeactive,  0 -10
      binde = , right , resizeactive,  10  0

      binde = SHIFT, H     , resizeactive, -50  0
      binde = SHIFT, J     , resizeactive,  0  50
      binde = SHIFT, K     , resizeactive,  0 -50
      binde = SHIFT, L     , resizeactive,  50  0
      binde = SHIFT, left  , resizeactive, -50  0
      binde = SHIFT, down  , resizeactive,  0  50
      binde = SHIFT, up    , resizeactive,  0 -50
      binde = SHIFT, right , resizeactive,  50  0

      bind  = , space , togglesplit,

      bind =  , ESCAPE, submap      , reset
      submap = reset
    '';
  };
}
