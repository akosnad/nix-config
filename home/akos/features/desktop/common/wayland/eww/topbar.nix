{ pkgs, ... }:
let
  get-workspaces = pkgs.writeScript "get-workspaces" /* bash */ ''
    spaces (){
        WORKSPACE_WINDOWS=$(hyprctl workspaces -j | ${pkgs.jq}/bin/jq 'map({key: .id | tostring, value: .windows}) | from_entries')
        seq 1 10 | ${pkgs.jq}/bin/jq --argjson windows "''${WORKSPACE_WINDOWS}" --slurp -Mc 'map(tostring) | map({id: ., windows: ($windows[.]//0)})'
    }

    spaces
    ${pkgs.socat}/bin/socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
        spaces
    done
  '';

  get-active-workspace = pkgs.writeScript "get-active-workspace" /* bash */ ''
    hyprctl monitors -j | jq --raw-output .[0].activeWorkspace.id
    ${pkgs.socat}/bin/socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | ${pkgs.coreutils}/bin/stdbuf -o0 grep '^workspace>>' | ${pkgs.coreutils}/bin/stdbuf -o0 ${pkgs.gawk}/bin/awk -F '>>|,' '{print $2}'
  '';

  get-window-title = pkgs.writeScript "get-window-title" /* bash */ ''
    initial="$(hyprctl activewindow -j | jq --raw-output .title)"
    if ! [ "$initial" = "null" ]; then
        echo "$initial"
    fi

    exec 4< <(${pkgs.socat}/bin/socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | ${pkgs.coreutils}/bin/stdbuf -o0 grep '^activewindow>>' | ${pkgs.coreutils}/bin/stdbuf -o0 ${pkgs.gawk}/bin/awk -F '>>|,' '{print $3}')
    exec 5< <(${pkgs.socat}/bin/socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | ${pkgs.coreutils}/bin/stdbuf -o0 grep '^activewindow2>>' | ${pkgs.coreutils}/bin/stdbuf -o0 ${pkgs.gawk}/bin/awk -F '>>|,' '{print $3}')
    exec 6< <(${pkgs.socat}/bin/socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | ${pkgs.coreutils}/bin/stdbuf -o0 grep '^closewindow>>' | ${pkgs.coreutils}/bin/stdbuf -o0 ${pkgs.gawk}/bin/awk -F '>>|,' '{print $3}')

    # print window title
    while read -r line; do
        echo "$line"
    done <&4 &

    # window close
    while read -r line; do
        ACTIVE_WINDOW="$line"
    done <&5 &

    # clear on window close
    while read -r line; do
        if [[ "$line" == "$ACTIVE_WINDOW" ]]; then
            echo ""
        fi
    done <&6 &

    wait $(jobs -p)
  '';

  get-keyboard-layout = pkgs.writeScript "get-keyboard-layout" /* bash */ ''
    list="$(hyprctl devices | ${pkgs.gnugrep}/bin/grep 'active keymap:' | ${pkgs.gawk}/bin/awk '{print $3}')"
    initial="en"
    for m in $list; do
        if [ "$m" != "English" ]; then
            initial="$(echo $m | ${pkgs.gnugrep}/bin/grep -Eo '^..' | tr '[:upper:]' '[:lower:]')"
            break
        fi
    done
    echo $initial

    ${pkgs.socat}/bin/socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | ${pkgs.coreutils}/bin/stdbuf -o0 grep '^activelayout>>' | ${pkgs.coreutils}/bin/stdbuf -o0 ${pkgs.gawk}/bin/awk -F '>>|,' '{print $3}' | ${pkgs.coreutils}/bin/stdbuf -o0 grep -Eo '^..' | ${pkgs.coreutils}/bin/stdbuf -o0 tr '[:upper:]' '[:lower:]'
  '';

in
pkgs.writeText "topbar.yuck" /* yuck */ ''
  (defwidget bar []
    (centerbox :orientation "h"
      :class "bar"
      (workspaces)
      (centerstuff)
      (sidestuff)
      )
    )

  (defwidget workspaces []
    (box :space-evenly false
      (for workspace in workspaces
        (eventbox :onclick "hyprctl dispatch workspace ''${workspace.id}"
                  :onscroll "scripts/switch-workspace {}"
          (box :class "warning workspace-entry ''${workspace.windows > 0 ? "occupied" : "empty"} ''${active_workspace == workspace.id ? "current" : "inactive"}"
            (label :text "''${workspace.id}")
            )
          )
        )
      (workspace_fix)
      )
    )

  (defwidget centerstuff []
    (box :class "centerstuff"
      (box
        (label :text "''${window}"
               :limit-width 50
               :tooltip "''${window}"
          )
        )
      )
    )

  (defwidget sidestuff []
    (box :class "sidestuff" :orientation "h" :space-evenly false :halign "end"
      (gap)
      (volume)
      (cpu)
      (ram)
      (disk)
      (batt)
      (systray)
      (label :text "''${keyboard_layout}" :class "kb-layout" )
      (label :text "''${time}" :class "time")
      )
    )

  (deflisten workspaces :initial "[]"
    "${get-workspaces}")

  (deflisten active_workspace :initial "1"
    "${get-active-workspace}")

  (deflisten window :initial ""
    "${get-window-title}")

  (deflisten keyboard_layout :initial ""
    "${get-keyboard-layout}")

  (defpoll time :interval "10s"
    "${pkgs.coreutils}/bin/date '+%b %d. %H:%M'")

  (defwindow topbar
    :monitor 0
    :windowtype "dock"
    :geometry (geometry :x "0%"
                        :y "0%"
                        :width "100%"
                        :height "10px"
                        :anchor "top center")
    :reserve (struts :side "top" :distance "10%")
    :exclusive true
    (bar))
''
