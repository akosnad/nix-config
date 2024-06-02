{ pkgs, config, ... }:
let
  hypr-socket = "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock";
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";

  get-window-title = pkgs.writeScript "get-window-title" /* bash */ ''
    initial="$(${hyprctl} activewindow -j | jq --raw-output .title)"
    if ! [ "$initial" = "null" ]; then
        echo "$initial"
    fi

    exec 4< <(${pkgs.socat}/bin/socat -u UNIX-CONNECT:${hypr-socket} - | ${pkgs.coreutils}/bin/stdbuf -o0 grep '^activewindow>>' | ${pkgs.coreutils}/bin/stdbuf -o0 ${pkgs.gawk}/bin/awk -F '>>|,' '{print $3}')
    exec 5< <(${pkgs.socat}/bin/socat -u UNIX-CONNECT:${hypr-socket} - | ${pkgs.coreutils}/bin/stdbuf -o0 grep '^activewindow2>>' | ${pkgs.coreutils}/bin/stdbuf -o0 ${pkgs.gawk}/bin/awk -F '>>|,' '{print $3}')
    exec 6< <(${pkgs.socat}/bin/socat -u UNIX-CONNECT:${hypr-socket} - | ${pkgs.coreutils}/bin/stdbuf -o0 grep '^closewindow>>' | ${pkgs.coreutils}/bin/stdbuf -o0 ${pkgs.gawk}/bin/awk -F '>>|,' '{print $3}')

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
in
pkgs.writeText "window_title.yuck" /* yuck */ ''
  (defwidget window_title []
    (box
      (label :text "''${window}"
             :limit-width 50
             :tooltip "''${window}"
      )
    )
  )

  (deflisten window :initial ""
    "${get-window-title}")
''
