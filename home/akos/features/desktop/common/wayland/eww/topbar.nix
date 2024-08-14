{ pkgs, lib, config, ... }:
let
  primary_monitor = lib.head (lib.filter (m: m.primary) config.monitors);
in
pkgs.writeText "topbar.yuck" /* yuck */ ''
  (defwidget bar []
    (centerbox :orientation "h"
      :class "bar"
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
      (systray)
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
''
