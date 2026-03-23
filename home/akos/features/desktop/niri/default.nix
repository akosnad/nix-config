{
  imports = [
    ../common
    ../common/wayland
  ];

  # this file also needs the host-wide niri config to be enabled!

  programs.niri = {
    enable = true;
    settings = {
      input = {
        keyboard = {
          track-layout = "global";
          repeat-delay = 150;
          repeat-rate = 50;
          xkb = {
            layout = "us,hu";
            options = "grp:caps_toggle";
          };
        };

        focus-follows-mouse.enable = true;
        mouse.accel-profile = "flat";
      };

      binds = {
        "Mod+Return".action.spawn = "kitty";
        "Mod+Q".action.spawn = "microsoft-edge";
        "Mod+Escape".action.close-window = { };
        "Mod+Shift+Escape".action.quit = { };
        "Mod+E".action.spawn = "nautilus";
        "Mod+F".action.toggle-window-floating = { };
        "Menu".action.spawn = "wofi --show drun,run";
        "Mod+Menu".action.spawn = "comma-gui";
        "Mod+Backspace".action.spawn = "toggle-theme";
        "Mod+N".action.spawn = "swaync-client -t";
        "Mod+G".action.spawn = "toggle-gammastep";
        "Mod+D".action.spawn = "hyprlock --immediate";
        "Mod+W".action.spawn = "cycle-wallpaper";
        "Alt+Space".action.toggle-overview = { };
      };
    };
  };
}
