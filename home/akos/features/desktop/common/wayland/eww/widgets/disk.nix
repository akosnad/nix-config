{pkgs, ... }:
let
  get-disk-info = pkgs.writeScript "get-disk-info" /* bash */ ''
    ${pkgs.coreutils}/bin/df -h --output=pcent,used,avail /
  '';
in
pkgs.writeText "disk.yuck" /* yuck */ ''
(defwidget disk []
  (eventbox :onhover "eww update disk_info_visible=true"
            :onhoverlost "eww update disk_info_visible=false"
    (box :space-evenly false
      (metric :label ""
              :active true
              :value {round((1 - (EWW_DISK["/"].free / EWW_DISK["/"].total)) * 100, 0)}
              :onchange "")
      (revealer :transition "slideleft"
                :reveal disk_info_visible
        (box :class "disk-info"
          (label :text "''${disk_info}")
          )
        )
      (gap)
      )
    )
  )
(defvar disk_info_visible false)
(defpoll disk_info :initial "" :interval "2s" :run-while disk_info_visible
  "${get-disk-info}")
''
