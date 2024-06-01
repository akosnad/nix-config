{ pkgs, ... }:
let
  toggle-notifications = pkgs.writeScriptBin "toggle-notifications" ''
    ${pkgs.swaynotificationcenter}/bin/swaync-client -t
  '';
in
pkgs.writeText "time.yuck" /* yuck */ ''
  (defwidget time []
    (eventbox
      :onclick "${toggle-notifications}/bin/toggle-notifications"
      (label :text "''${time}" :class "time")
    )
  )

  (defpoll time :interval "10s"
    "${pkgs.coreutils}/bin/date '+%b %d. %H:%M'")
''
