{ pkgs, ... }: pkgs.writeText "music.yuck" /* yuck */ ''
  (defwidget music []
    (box :class "music"
         :orientation "h"
         :space-evenly false
         :halign "center"
      {music != "" ? "🎵''${music}" : ""}))
  (deflisten music :initial ""
    "${pkgs.playerctl}/bin/playerctl --follow metadata --format '{{ artist }} - {{ title }}' || true")
''
