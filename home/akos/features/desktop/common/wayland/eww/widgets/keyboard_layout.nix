{ pkgs, config, ... }:
let
  hypr-socket = "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock";
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";

  get-keyboard-layout = pkgs.writeScript "get-keyboard-layout" /* bash */ ''
    list="$(${hyprctl} devices | ${pkgs.gnugrep}/bin/grep 'active keymap:' | ${pkgs.gawk}/bin/awk '{print $3}')"
    initial="en"
    for m in $list; do
        if [ "$m" != "English" ]; then
            initial="$(echo $m | ${pkgs.gnugrep}/bin/grep -Eo '^..' | tr '[:upper:]' '[:lower:]')"
            break
        fi
    done
    echo $initial

    ${pkgs.socat}/bin/socat -u UNIX-CONNECT:${hypr-socket} - | ${pkgs.coreutils}/bin/stdbuf -o0 grep '^activelayout>>' | ${pkgs.coreutils}/bin/stdbuf -o0 ${pkgs.gawk}/bin/awk -F '>>|,' '{print $3}' | ${pkgs.coreutils}/bin/stdbuf -o0 grep -Eo '^..' | ${pkgs.coreutils}/bin/stdbuf -o0 tr '[:upper:]' '[:lower:]'
  '';

in
pkgs.writeText "keyboard_layout.yuck" /* yuck */ ''
  (defwidget keyboard_layout []
    (label :text "''${keyboard_layout}" :class "kb-layout" )
  )

  (deflisten keyboard_layout :initial ""
    "${get-keyboard-layout}")
''
