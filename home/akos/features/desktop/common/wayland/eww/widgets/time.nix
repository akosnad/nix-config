{ pkgs, ... }: pkgs.writeText "time.yuck" /* yuck */ ''
(defwidget time []
  (label :text "''${time}" :class "time")
)

(defpoll time :interval "10s"
  "${pkgs.coreutils}/bin/date '+%b %d. %H:%M'")
''
