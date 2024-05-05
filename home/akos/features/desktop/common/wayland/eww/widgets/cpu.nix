{ pkgs, ... }: pkgs.writeText "cpu.yuck" /* yuck */ ''
(defwidget cpu []
  (eventbox :onhover "eww update cpu_info_visible=true"
            :onhoverlost "eww update cpu_info_visible=false"
    (box :space-evenly false
      (metric :label "cpu"
              :active true
              :value {EWW_CPU.avg}
              :onchange "")
      (revealer :transition "slideleft"
                :reveal cpu_info_visible
        (box :class "cpu-info"
          (label :text "''${round(EWW_CPU.avg, 0)}%''${EWW_TEMPS.CORETEMP_PACKAGE_ID_0 != "" ? "  ''${EWW_TEMPS.CORETEMP_PACKAGE_ID_0}°C" : ""}")
          )
        )
      (gap)
      )
    )
  )
(defvar cpu_info_visible false)
''
