{ pkgs, lib, config, ... }:
let
  hypr-socket = "\"$XDG_RUNTIME_DIR\"/hypr/\"$HYPRLAND_INSTANCE_SIGNATURE\"/.socket2.sock";
  primary_monitor = lib.head (lib.filter (m: m.primary) config.monitors);

  hasFullscreen = pkgs.writeShellApplication {
    name = "hasFullscreen";
    runtimeInputs = [
      config.wayland.windowManager.hyprland.package
      config.programs.eww.package
    ] ++ (with pkgs; [
      coreutils
      jq
      socat
    ]);
    text = ''
      get_state() {
        active_workspace="$(hyprctl monitors -j | jq -r '.[] | select(.name == "${primary_monitor.name}") | .activeWorkspace.id')"
        window_count="$(hyprctl clients -j | jq ".[] | select(.workspace.id == $active_workspace)" | jq -es 'length')"
        # if there is only one window, we can assume it's fullscreen
        # also, if there are no windows, we act as if there are multiple windows present
        if [[ "$window_count" -eq 1 ]]; then
          echo 1
        else
          echo 0
        fi
      }

      # set initially
      get_state

      # listen for window state changes
      socat -u UNIX-CONNECT:${hypr-socket} - | while read -r line; do
        if [[ "$line" == activewindow* ]]; then
          get_state
        fi
      done
    '';
  };
in
pkgs.writeText "topbar.yuck" /* yuck */ ''
  (defwidget bar []
    (centerbox :orientation "h"
      :class "bar''${hasFullscreen == "1" ? "" : " bar-gapped"}"
      (leftstuff)
      (centerstuff)
      (sidestuff)
      )
    )

  (defwidget leftstuff []
    (box :class "leftstuff" :orientation "h" :space-evenly false :halign "start"
      (workspaces)
      (gap)
      (window_title)
    )
  )

  (defwidget centerstuff []
    (box :class "centerstuff"
      (gap)
      )
    )

  (defwidget sidestuff []
    (box :class "sidestuff" :orientation "h" :space-evenly false :halign "end"
      (gap)
      (securitykey)
      (volume)
      (cpu)
      (ram)
      (disk)
      (battery)
      (systray :spacing 2)
      (keyboard_layout)
      (time)
      )
    )

  (defwindow topbar
    :monitor "${primary_monitor.model}"
    :windowtype "dock"
    :geometry (geometry :x "0%"
                        :y "0%"
                        :width "${builtins.toString (primary_monitor.width / primary_monitor.scale)}px"
                        :height "10px"
                        :anchor "top center")
    :reserve (struts :side "top" :distance "10%")
    :exclusive true
    (bar)
  )

  (deflisten hasFullscreen :initial "0"
    "${lib.getExe hasFullscreen}")
''
