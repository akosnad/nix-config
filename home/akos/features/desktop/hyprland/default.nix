{ pkgs, lib, config, ... }:
{
  imports = [
    ../common
    ./binds.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.inputs.hyprland.hyprland.override { wrapRuntimeDeps = false; };
    systemd = {
      enable = true;
      # Same as default, but stop graphical-session too
      extraCommands = lib.mkBefore [
        "systemctl --user stop graphical-session.target"
        "systemctl --user start hyprland-session.target"
      ];
    };

    settings =
      let
        active = "0xaa${config.colorscheme.palette.base0C}";
        inactive = "0xaa${config.colorscheme.palette.base02}";
      in
      {
        monitor = [ ",preferred,auto,1" ];


        # exec-once = systemctl start --user hyprland-session.service & /usr/lib/polkit-kde-authentication-agent-1 & eww daemon & eww open topbar

        input = {
          kb_layout = "us,hu";
          kb_options = "grp:caps_toggle";
          kb_rules = "evdev";
          repeat_rate = 50;
          repeat_delay = 150;

          follow_mouse = 1;

          touchpad = {
            natural_scroll = "yes";
            tap-to-click = "yes";
            drag_lock = "yes";
          };

          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        };

        general = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          gaps_in = 5;
          gaps_out = 0;
          border_size = 0;
          # col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          "col.active_border" = "rgba(ffffffaa)";
          "col.inactive_border" = "rgba(595959aa)";

          layout = "dwindle";

          cursor_inactive_timeout = 1;
        };

        misc = {
          disable_hyprland_logo = "yes";
          vfr = "yes";
        };

        decoration = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          rounding = 10;
          #blur = no
          #blur_size = 3
          #blur_passes = 1
          #blur_new_optimizations = on

          drop_shadow = "yes";
          shadow_range = 4;
          shadow_render_power = 3;
          "col.shadow" = "rgba(1a1a1aee)";
        };

        animations = {
          enabled = "yes";

          # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = [ "myBezier, 0.05, 0.9, 0.1, 1.05" ];

          animation = [
            "windows, 1, 3, myBezier"
            "windowsOut, 1, 3, default, popin 80%"
            "border, 0, 10, default"
            "borderangle, 0, 8, default"
            "fade, 1, 3, default"
            "workspaces, 1, 3, myBezier"
          ];
        };

        dwindle = {
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          pseudotile = "no"; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = "yes"; # you probably want this
        };

        master = {
          # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
          new_is_master = true;
        };

        gestures = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          workspace_swipe = true;
          workspace_swipe_fingers = 4;
        };
      };
  };

  # FIXME: separate packages and their configs to desktop/common/ modules
  home.packages = with pkgs; [
    wofi
    swaynotificationcenter
  ];
}