{ pkgs, config, ... }:
let
  eww = "${config.programs.eww.package}/bin/eww";

  battery_icon = pkgs.writeScript "battery_icon" /* bash */ ''
    function get_info() {
      battery="$1"

        state="$(${pkgs.upower}/bin/upower -i $battery | ${pkgs.gnugrep}/bin/grep state | ${pkgs.gawk}/bin/awk '{print $2}')"
        percentage="$(${pkgs.upower}/bin/upower -i $battery | ${pkgs.gnugrep}/bin/grep percentage | ${pkgs.gawk}/bin/awk '{print $2}' | ${pkgs.gawk}/bin/awk -F% '{print $1}')"

        if [[ "$state" == "discharging" ]]; then
          if (( "$percentage" > 95 )) then
            echo "󰁹"
          elif (( "$percentage" > 90 )) then
            echo "󰂂"
          elif (( "$percentage" > 80 )); then
            echo "󰂁"
          elif (( "$percentage" > 70 )); then
            echo "󰂀"
          elif (( "$percentage" > 60 )); then
            echo "󰁿"
          elif (( "$percentage" > 50 )); then
            echo "󰁾"
          elif (( "$percentage" > 40 )); then
            echo "󰁽"
          elif (( "$percentage" > 30 )); then
            echo "󰁼"
          elif (( "$percentage" > 20 )); then
            echo "󰁻"
          elif (( "$percentage" > 10 )); then
            echo "󰁺"
          else
            echo "󰂎"
          fi
        elif [[ "$state" == "charging" ]]; then
          if (( "$percentage" > 95 )); then
            echo "󰂅"
          elif (( "$percentage" > 90 )); then
            echo "󰂋"
          elif (( "$percentage" > 80 )); then
            echo "󰂊"
          elif (( "$percentage" > 70 )); then
            echo "󰢞"
          elif (( "$percentage" > 60 )); then
            echo "󰂉"
          elif (( "$percentage" > 50 )); then
            echo "󰢝"
          elif (( "$percentage" > 40 )); then
            echo "󰂈"
          elif (( "$percentage" > 30 )); then
            echo "󰂇"
          elif (( "$percentage" > 20 )); then
            echo "󰂆"
          elif (( "$percentage" > 10 )); then
            echo "󰢜"
          else
            echo "󰢟"
          fi
        else
            echo "󱃍"
        fi
    }

    # get initial state
    battery_initial="$(${pkgs.upower}/bin/upower -e | ${pkgs.gnugrep}/bin/grep -E "battery|BAT" | ${pkgs.gnugrep}/bin/grep -oE "(/\w+)+/battery_BAT[0-9]+$")"
    if [[ -n "$battery_initial" ]]; then
        ${eww} update has_battery=true
        get_info $battery_initial
    else
        # host doesn't have a battery
        exit 0
    fi

    # listen to events
    ${pkgs.upower}/bin/upower -m | ${pkgs.coreutils}/bin/stdbuf -o0 ${pkgs.gnugrep}/bin/grep -E "battery|BAT" | ${pkgs.coreutils}/bin/stdbuf -o0 ${pkgs.gnugrep}/bin/grep -oE "(/\w+)+/battery_BAT[0-9]+$" | while read -r battery; do
        get_info $battery
    done
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

    # find out if host has a battery
    battery_initial="$(${pkgs.upower}/bin/upower -e | ${pkgs.gnugrep}/bin/grep -E "battery|BAT" | ${pkgs.gnugrep}/bin/grep -oE "(/\w+)+/battery_BAT[0-9]+$")"
    if [[ -z "$battery_initial" ]]; then
        # host doesn't have a battery
        exit 0
    fi

    ${pkgs.upower}/bin/upower -e | ${pkgs.gnugrep}/bin/grep -E "battery|BAT" | while read -r battery; do
        get_info $battery
    done

    # listen to upower events that are sent when the battery state changes
    ${pkgs.upower}/bin/upower -m | ${pkgs.coreutils}/bin/stdbuf -o0 ${pkgs.gnugrep}/bin/grep -E "battery|BAT" | ${pkgs.coreutils}/bin/stdbuf -o0 ${pkgs.gnugrep}/bin/grep -oE "(/\w+)+/battery_BAT[0-9]+$" | while read -r battery; do
        get_info $battery
    done
  '';


in
pkgs.writeText "battery.yuck" /* yuck */ ''
  (defwidget battery []
    (eventbox :onhover "${eww} update battery=true"
              :onhoverlost "${eww} update battery=false"
              :visible has_battery
      (box :space-evenly false
        (label :text "''${battery_icon}"
                :active true
                :value {EWW_BATTERY.total_avg}
                :onchange "")
        (revealer :transition "slideleft"
                  :reveal battery
          (box :class "gap"
            (label :text "''${battery_info}")
            )
          )
        (gap)
        )
      )
    )
  (defvar battery false)
  (defvar has_battery false)
  (deflisten battery_info :initial ""
    "${get-batt-info}")
  (deflisten battery_icon :initial ""
    "${battery_icon}")
''
