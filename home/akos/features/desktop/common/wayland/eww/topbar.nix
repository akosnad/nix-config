{ pkgs, ... }: pkgs.writeText "topbar.yuck" /* yuck */ ''
  (defwidget bar []
    (centerbox :orientation "h"
      :class "bar"
      (workspaces)
      (centerstuff)
      (sidestuff)
      )
    )

  (defwidget centerstuff []
    (box :class "centerstuff"
      (window_title)
      )
    )

  (defwidget sidestuff []
    (box :class "sidestuff" :orientation "h" :space-evenly false :halign "end"
      (gap)
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
