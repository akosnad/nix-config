{ config, ...}:
let
  inherit (config.colorscheme) colors;
  primaryMonitor = builtins.head (builtins.filter (m: m.primary) config.monitors);
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

      input-field = [
        {
          size = "250, 50";
          position = "0, 0";
          halign = "center";
          valign = "center";
          monitor = primaryMonitor.name;
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(${colors.base07})";
          inner_color = "rgb(${colors.base01})";
          outer_color = "rgb(${colors.base02})";
          outline_thickness = 5;
          placeholder_text = "Password...";
          shadow_passes = 2;
        }
      ];

      label = [
        {
          monitor = primaryMonitor.name;
          font_size = 32;
          font_family = "Terminus";
          position = "0, 80";
          valign = "center";
          halign = "center";
          text = "cmd[update:500] date +%H:%M:%S";
        }
      ];
    };
  };
}
