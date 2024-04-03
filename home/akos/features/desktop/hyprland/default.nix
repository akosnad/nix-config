{ pkgs, lib, config, ... }:
{
  imports = [
    ../common
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
        input = {
          kb_layout = "us,hu";
          kb_options = "grp:caps_toggle";
          kb_rules = "evdev";
          repeat_rate = 50;
          repeat_delay = 150;

          follow_mouse = 1;

          touchpad = {
            natural_scroll = "yes";
            "tap-to-click" = "yes";
            drag_lock = "yes";
          };
        };
        general = {
          gaps_in = 5;
          gaps_out = 0;
          border_size = 0;
          "col.active_border" = active;
          "col.inactive_border" = inactive;
          layout = "dwindle";
          cursor_inactive_timeout = 1;
        };
        dwindle = {
          pseudotile = "no";
          preserve_split = "yes";
        };
        master = {
          new_is_master = true;
        };
        misc = {
          disable_hyprland_logo = "yes";
          vfr = "yes";
        };

        decoration = {
          rounding = 10;
          drop_shadow = "yes";
          shadow_range = 4;
          shadow_render_power = 3;
          "col.shadow" = "0xaa${config.colorscheme.palette.base03}";
        };

        animations = {
          enabled = "yes";
          animation = [
            "windows, 1, 3, myBezier"
            "windowsOut, 1, 3, default, popin 80%"
            "border, 0, 10, default"
            "borderangle, 0, 8, default"
            "fade, 1, 3, default"
            "workspaces, 1, 3, myBezier"
          ];
        };

        gestures = {
          workspace_swipe = true;
          workspace_swipe_fingers = 4;
        };

        "$mainMod" = "SUPER";
        "$browser" = "xdg-open http://";

        bind = [
          "$mainMod, Return, exec, alacritty"
          "$mainMod, Space, togglesplit,"

          "bind = $mainMod, N, exec, swaync-client -t"
          "bind = $mainMod, G, exec, ~/dotfiles/hypr/toggle-gammastep.sh"

          # Workspaces
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"

          "$mainMod, SHIFT, 1, movetoworkspace, 1"
          "$mainMod, SHIFT, 2, movetoworkspace, 2"
          "$mainMod, SHIFT, 3, movetoworkspace, 3"
          "$mainMod, SHIFT, 4, movetoworkspace, 4"
          "$mainMod, SHIFT, 5, movetoworkspace, 5"
          "$mainMod, SHIFT, 6, movetoworkspace, 6"
          "$mainMod, SHIFT, 7, movetoworkspace, 7"
          "$mainMod, SHIFT, 8, movetoworkspace, 8"
          "$mainMod, SHIFT, 9, movetoworkspace, 9"
          "$mainMod, SHIFT, 0, movetoworkspace, 10"

          "$mainMod SHIFT, left, movetoworkspace, -1"
          "$mainMod SHIFT, right, movetoworkspace, +1"

          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"

          # Screenshot
          ",Print, exec, grimblast --notify copy"
          "ALT, Print, exec, grimblast --notify copy active"
          "$mainMod, Print, exec, grimblast --notify copy area"

          # move current workspace between monitors
          "SUPERALT, left, movecurrentworkspacetomonitor, -1"
          "SUPERALT, right, movecurrentworkspacetomonitor, +1"
        ];

        bindle = [
          ",XF86MonBrightnessUp, exec, light -A 5"
          ",XF86MonBrightnessDown, exec, light -U 5"

          ",XF86AudioRaiseVolume, exec, amixer -q set Master 5%+"
          ",XF86AudioLowerVolume, exec, amixer -q set Master 5%-"
          ",XF86AudioMute, exec, amixer -q set Master toggle"
          ",XF86AudioPlay, exec, playerctl play-pause"
          ",XF86AudioPause, exec, playerctl play-pause"
        ];
      };
  };
}
