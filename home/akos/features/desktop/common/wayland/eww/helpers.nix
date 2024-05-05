{ pkgs, ... }: pkgs.writeText "helpers.yuck" /* yuck */ ''
  (defwidget gap []
    (box :class "gap")
  )

  (defwidget metric [label value onchange active]
    (box :orientation "h"
         :class "metric"
         :space-evenly false
      (box :class "label" label)
        (scale :min 0
               :max 101
               :active {onchange != ""}
               :value value
               :onchange onchange
        )
      )
  )
''
