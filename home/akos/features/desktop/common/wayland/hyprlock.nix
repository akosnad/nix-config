{ config, ... }:
let
  primaryMonitor = builtins.head (builtins.filter (m: m.primary) config.monitors);
  fontFamily = config.fontProfiles.regular.family;
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
      ];
    };
  };
}
