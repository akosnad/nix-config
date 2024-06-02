{ pkgs, config, ... }:
let
  eww = "${config.programs.eww.package}/bin/eww";

  # taken from: https://unix.stackexchange.com/a/719258
  getvol = pkgs.writeScript "getvol" /* bash */ ''
    get_vol() {
      ${pkgs.alsa-utils}/bin/amixer sget Master | ${pkgs.gnugrep}/bin/grep 'Left:' | ${pkgs.gawk}/bin/awk -F'[][]' '{ print $2 }' | ${pkgs.coreutils}/bin/tr -d '%' | ${pkgs.coreutils}/bin/head -1
    }

    get_vol

    skip=1
    stdbuf -oL ${pkgs.alsa-utils}/bin/amixer events |
      while IFS= read -r line; do
        case ''${line%%,*} in
          ('event value: numid='[34])
            if [ "$skip" -eq 0 ]; then
              get_vol
            else
              skip=$(( skip - 1 ))
            fi
        esac
      done
  '';

  volume_icon = pkgs.writeScript "volume_icon" /* bash */ ''
    get_icon() {
      vol="$(${pkgs.alsa-utils}/bin/amixer sget Master | ${pkgs.gawk}/bin/awk -F'[][]' '/Left:/ {print 0+$2 ($4 == "off" ? "!" : "")}')"
      echo $vol
      
      if (( "$vol" < 1 )); then
        echo ""
      elif (( "$vol" < 33 )); then
        echo ""
      elif (( "$vol" < 66 )); then
        echo ""
      else
        echo ""
      fi
    }

    get_icon

    skip=1
    stdbuf -oL ${pkgs.alsa-utils}/bin/amixer events |
      while IFS= read -r line; do
        case ''${line%%,*} in
          ('event value: numid='[34])
            if [ "$skip" -eq 0 ]; then
              get_icon
            else
              skip=$(( skip - 1 ))
            fi
        esac
      done
  '';
in
pkgs.writeText "volume.yuck" /* yuck */ ''
  (defwidget volume []
    (eventbox :onhover "${eww} update volume_info_visible=true"
              :onhoverlost "${eww} update volume_info_visible=false"
      (box :space-evenly false
        (metric :label "''${volume_icon}"
                :value volume
                :active true
                :onchange "${pkgs.alsa-utils}/bin/amixer sset Master {}% && ${eww} update volume={}")
        (revealer :transition "slideleft"
                  :reveal volume_info_visible
          (eventbox :onclick "${pkgs.playerctl}/bin/playerctl play-pause"
            :class "volume-info"
             (label :text "''${volume}%''${player_status == 'Playing' ? ' >' : player_status == 'Paused' ? ' ||' : '''}''${now_playing != ''' ? ' ' + now_playing : '''}")
            )
          )
        (gap)
        )
      )
    )
  (defvar volume_info_visible false)
  (deflisten volume_icon
    "${volume_icon}")
  (deflisten volume
    "${getvol}")
  (deflisten now_playing :initial ""
    "${pkgs.playerctl}/bin/playerctl -F metadata --format '{{ artist }} - {{ title }} {{playing}}' || true")
  (deflisten player_status :initial ""
    "${pkgs.playerctl}/bin/playerctl -F metadata --format '{{status}}' || true")
''
