{ pkgs, lib, config, ... }:
let
  primaryMonitor = builtins.head (builtins.filter (m: m.primary) config.monitors);
  fontFamily = config.fontProfiles.regular.family;

  batteryInfo = pkgs.writeShellApplication {
    name = "hyprlock-battery-info";
    runtimeInputs = with pkgs; [ upower ];
    text = ''
      BAT="$(upower -e | grep battery_BAT | head -n1)"
      if [[ "$BAT" == "" ]]; then
        echo
        exit 0
      fi
      DATA="$(upower -i "$BAT")"

      percentage="$(echo "$DATA" | grep 'percentage:' | awk '{print $2}')"
      state="$(echo "$DATA" | grep 'state:' | awk '{print $2}')"

      charging=("󰢟 " "󰢜 " "󰂆 " "󰂇 " "󰂈 " "󰢝 " "󰂉 " "󰢞 " "󰂊 " "󰂋 " "󰂅 ")
      discharging=("󰂎 " "󰁺 " "󰁻 " "󰁼 " "󰁽 " "󰁾 " "󰁿 " "󰂀 " "󰂁 " "󰂂 " "󰁹 ")
      pct="$(echo "$percentage" | cut -f1 -d'%')"
      icon_index=$((pct / 10))
      if [[ "$state" == "charging" ]]; then
        icon="''${charging[$icon_index]}"
      else
        icon="''${discharging[$icon_index]}"
      fi

      printf "%s\n" "$icon $percentage"
    '';
  };
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 5;
        hide_cursor = true;
        no_fade_in = false;
        disable_loading_bar = true;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
          noise = 0.0117;
        }
      ];

      label = [
        {
          monitor = primaryMonitor.name;
          font_size = 32;
          font_family = fontFamily;
          position = "0, 0";
          valign = "center";
          halign = "center";
          text = "cmd[update:500] date +%H:%M:%S";
        }
        {
          monitor = primaryMonitor.name;
          font_size = 16;
          font_family = fontFamily;
          position = "0, -36";
          valign = "center";
          halign = "center";
          text = "cmd[update:500] date +'%b %d. %A'";
        }
        {
          monitor = primaryMonitor.name;
          font_size = 12;
          font_family = fontFamily;
          position = "0, -72";
          valign = "center";
          halign = "center";
          text = "cmd[update:30000] ${lib.getExe batteryInfo}";
        }
      ];
    };
  };
}
