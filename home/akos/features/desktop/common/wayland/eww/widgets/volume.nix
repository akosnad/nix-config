{ pkgs, ... }:
let
  getvol = pkgs.writeScript "getvol" /* bash */ ''
    ${pkgs.alsa-utils}/bin/amixer sget Master | ${pkgs.gnugrep}/bin/grep 'Left:' | ${pkgs.gawk}/bin/awk -F'[][]' '{ print $2 }' | ${pkgs.coreutils}/bin/tr -d '%' | ${pkgs.coreutils}/bin/head -1
  '';
in
pkgs.writeText "volume.yuck" /* yuck */ ''
(defwidget volume []
  (eventbox :onhover "eww update volume_info_visible=true"
            :onhoverlost "eww update volume_info_visible=false"
    (box :space-evenly false
      (metric :label "vol"
              :value volume
              :active true
              :onchange "${pkgs.alsa-utils}/bin/amixer sset Master {}% && eww update volume={}")
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
(defpoll volume :interval "1s"
  "${getvol}")
(deflisten now_playing :initial ""
  "${pkgs.playerctl}/bin/playerctl -F metadata --format '{{ artist }} - {{ title }} {{playing}}' || true")
(deflisten player_status :initial ""
  "${pkgs.playerctl}/bin/playerctl -F metadata --format '{{status}}' || true")
''
