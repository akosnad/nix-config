{ pkgs, ... }: 
let
  getvol = pkgs.writeScript "getvol" /* bash */ ''
    ${pkgs.alsa-utils}/bin/amixer sget Master | ${pkgs.gnugrep}/bin/grep 'Left:' | ${pkgs.gawk}/bin/awk -F'[][]' '{ print $2 }' | ${pkgs.coreutils}/bin/tr -d '%' | ${pkgs.coreutils}/bin/head -1
  '';

  get-batt-info = pkgs.writeScript "get-batt-info" /* bash */ ''
    function get_info() {
        battery="$1"

        state="$(${pkgs.upower}/bin/upower -i $battery | ${pkgs.gnugrep}/bin/grep state | ${pkgs.gawk}/bin/awk '{print $2}')"
        percentage="$(${pkgs.upower}/bin/upower -i $battery | ${pkgs.gnugrep}/bin/grep percentage | ${pkgs.gawk}/bin/awk '{print $2}')"
        time_to_empty="$(${pkgs.upower}/bin/upower -i $battery | ${pkgs.gnugrep}/bin/grep time | ${pkgs.gnugrep}/bin/grep empty | ${pkgs.gawk}/bin/awk '{print $4,$5}')"
        time_to_full="$(${pkgs.upower}/bin/upower -i $battery | ${pkgs.gnugrep}/bin/grep time | ${pkgs.gnugrep}/bin/grep full | ${pkgs.gawk}/bin/awk '{print $4,$5}')"
        if [[ "$state" == "discharging" ]]; then
            echo "''${percentage}- $time_to_empty"
        elif [[ "$state" == "charging" ]]; then
            echo "''${percentage}+ $time_to_full"
        else
            echo "''${percentage}"
        fi
    }

    ${pkgs.upower}/bin/upower -e | ${pkgs.gnugrep}/bin/grep -E "battery|BAT" | while read -r battery; do
        get_info $battery
    done

    # listen to upower events that are sent when the battery state changes
    ${pkgs.upower}/bin/upower -m | ${pkgs.coreutils}/bin/stdbuf -o0 ${pkgs.gnugrep}/bin/grep -E "battery|BAT" | ${pkgs.coreutils}/bin/stdbuf -o0 ${pkgs.gnugrep}/bin/grep -oE "(/\w+)+/battery_BAT[0-9]+$" | while read -r battery; do
        get_info $battery
    done
  '';

  get-disk-info = pkgs.writeScript "get-disk-info" /* bash */ ''
    ${pkgs.coreutils}/bin/df -h --output=pcent,used,avail /
  '';

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

in pkgs.writeText "widgets.yuck" /* yuck */ ''
(defwidget batt []
  (eventbox :onhover "eww update batt=true"
            :onhoverlost "eww update batt=false"
    (box :space-evenly false
      (metric :label "batt"
              :active true
              :value {EWW_BATTERY.total_avg}
              :onchange "")
      (revealer :transition "slideleft"
                :reveal batt
        (box :class "batt-info"
          (label :text "''${battery_info}")
          )
        )
      (gap)
      )
    )
  )
(defvar batt false)
(deflisten battery_info :initial ""
  "${get-batt-info}")


(defwidget music []
  (box :class "music"
       :orientation "h"
       :space-evenly false
       :halign "center"
    {music != "" ? "🎵''${music}" : ""}))
(deflisten music :initial ""
  "${pkgs.playerctl}/bin/playerctl --follow metadata --format '{{ artist }} - {{ title }}' || true")


(defwidget disk []
  (eventbox :onhover "eww update disk_info_visible=true"
            :onhoverlost "eww update disk_info_visible=false"
    (box :space-evenly false
      (metric :label "disk"
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


(defwidget ram []
  (eventbox :onhover "eww update ram_info_visible=true"
            :onhoverlost "eww update ram_info_visible=false"
    (box :space-evenly false
      (metric :label "ram"
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


(defwidget volume []
  (eventbox :onhover "eww update volume_info_visible=true"
            :onhoverlost "eww update volume_info_visible=false"
    (box :space-evenly false
      (metric :label "vol"
              :value volume
              :active true
              :onchange "${pkgs.alsa-utils}/bin/amixer sset Master {}% && eww update volume={}")
      (revealer :transition "slideleft"
                :reveal volume_info_visible
        (eventbox :onclick "${pkgs.playerctl}/bin/playerctl play-pause"
          :class "volume-info"
           (label :text "''${volume}%''${player_status == 'Playing' ? ' >' : player_status == 'Paused' ? ' ||' : '''}''${now_playing != ''' ? ' ' + now_playing : '''}")
          )
        )
      (gap)
      )
    )
  )
(defvar volume_info_visible false)
(defpoll volume :interval "1s"
  "${getvol}")
(deflisten now_playing :initial ""
  "${pkgs.playerctl}/bin/playerctl -F metadata --format '{{ artist }} - {{ title }} {{playing}}' || true")
(deflisten player_status :initial ""
  "${pkgs.playerctl}/bin/playerctl -F metadata --format '{{status}}' || true")
''
