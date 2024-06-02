{ pkgs, ... }: pkgs.writeText "topbar.yuck" /* yuck */ ''
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
    (bar)
  )
''
