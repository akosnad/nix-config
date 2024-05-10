{ pkgs, ... }:
let
  get-ram-info = pkgs.writeScript "get-ram-info" /* bash */ ''
    out="$(${pkgs.procps}/bin/free -m | ${pkgs.gnugrep}/bin/grep -E '^Mem:')"
    used="$(echo $out | ${pkgs.gawk}/bin/awk '{print $3}')"
    free="$(echo $out | ${pkgs.gawk}/bin/awk '{print $4}')"
    shared="$(echo $out | ${pkgs.gawk}/bin/awk '{print $5}')"
    cache="$(echo $out | ${pkgs.gawk}/bin/awk '{print $6}')"
    available="$(echo $out | ${pkgs.gawk}/bin/awk '{print $7}')"
    perc=$(echo $out | ${pkgs.gawk}/bin/awk '{print ($3/$2)*100}')

    ${pkgs.coreutils}/bin/printf 'Use%%\tUsed\tAvail\tBuf/cache\n'
    ${pkgs.coreutils}/bin/printf '%.0f%%\t%dM\t%dM\t%dM' "$perc" "$used" "$available" "$cache"
  '';
in
pkgs.writeText "ram.yuck" /* yuck */ ''
  (defwidget ram []
    (eventbox :onhover "eww update ram_info_visible=true"
              :onhoverlost "eww update ram_info_visible=false"
      (box :space-evenly false
        (metric :label ""
                :active true
                :value {EWW_RAM.used_mem_perc}
                :onchange "")
        (revealer :transition "slideleft"
                  :reveal ram_info_visible
          (box :class "ram-info"
            (label :text "''${ram_info}")
            )
          )
        (gap)
        )
      )
    )
  (defvar ram_info_visible false)
  (defpoll ram_info :initial "" :interval "1s" :run-while ram_info_visible
    "${get-ram-info}")
''
