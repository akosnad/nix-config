{ pkgs, lib, config, ... }:
{
  imports = [
    ../common
    ../common/wayland

    ./binds.nix
    ./wallpaper.nix
  ];

  # FIXME: separate packages and their configs to desktop/common/ modules
  home.packages = with pkgs; [
    wofi
  ];

  xdg.portal = {
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    configPackages = [ config.wayland.windowManager.hyprland.package ];
  };

  xdg.dataFile."icons/Quintom Ink".source = "${pkgs.quintom-ink-hyprcursor}/usr/share/icons/Quintom Ink";
  xdg.dataFile."icons/Quintom Snow".source = "${pkgs.quintom-snow-hyprcursor}/usr/share/icons/Quintom Snow";

  specialisation = {
    dark.configuration.wayland.windowManager.hyprland.settings = {
      env = [ "HYPRCURSOR_THEME,Quintom Ink" ];
      exec = [ "hyprctl setcursor \"Quintom Ink\" 24" ];
    };
    light.configuration.wayland.windowManager.hyprland.settings = {
      env = [ "HYPRCURSOR_THEME,Quintom Snow" ];
      exec = [ "hyprctl setcursor \"Quintom Snow\" 24" ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    plugins = with pkgs.hyprlandPlugins; [
      hyprexpo
      hyprscroller
    ];
    systemd = {
      enable = true;
      # Same as default, but stop graphical-session too
      extraCommands = lib.mkBefore [
        "systemctl --user stop graphical-session.target"
        "systemctl --user start hyprland-session.target"
      ];
      variables = [ "--all" ];
    };

    settings =
      let
        palette = config.lib.stylix.colors;
        inherit (palette) variant;
        activeOpacity = "55";
        inactiveOpacity = "22";
        selection = "0x${activeOpacity}${palette.base08}";
        active = "0x${activeOpacity}${palette.base0C}";
        # inactive = "0x${inactiveOpacity}${palette.base02}";
        shadow = if variant == "light" then "0x${activeOpacity}${palette.base07}" else "0x${activeOpacity}${palette.base00}";
        shadowInactive = if variant == "light" then "0x${inactiveOpacity}${palette.base07}" else "0x${inactiveOpacity}${palette.base00}";
      in
      {
        monitor = map
          (
            m:
            let
              resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
              position = "${toString m.x}x${toString m.y}";
              scale = "${toString m.scale}";
              vrr = if m.vrr != null then "vrr, ${toString m.vrr}" else "";
            in
            "${m.name},${
          if m.enabled
          then (lib.pipe [ resolution position scale vrr ] [
            (lib.filter (s: s != "" && s != null))
            (lib.concatStringsSep ",")
          ])
          else "disable"
        }"
          )
          config.monitors;

        workspace = [
          "w[tv1], gapsout:0, gapsin:0"
          "f[1], gapsout:0, gapsin:0"
        ] ++ map (m: "${m.name},${m.workspace}") (
          lib.filter (m: m.enabled && m.workspace != null) config.monitors
        );

        xwayland.force_zero_scaling = true;

        ecosystem.no_update_news = true;

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
          gaps_out = 10;
          border_size = 0;

          layout = "scroller";
        };

        cursor = {
          inactive_timeout = 1;
        };

        env = [
          "HYPRCURSOR_SIZE,24"
          "XDG_SESSION_TYPE,wayland"
        ];

        misc = {
          vfr = "yes";
        };

        decoration = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          rounding = 10;
          #blur = no
          #blur_size = 3
          #blur_passes = 1
          #blur_new_optimizations = on

          shadow = {
            enabled = true;
            range = 18;
            render_power = 2;
            sharp = false;
            ignore_window = true;

            # not-as-strong shadow colors
            color = lib.mkForce shadow;
            color_inactive = lib.mkForce shadowInactive;
          };
        };

        animations = {
          enabled = "yes";

          # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = [ "custom, 0.22, 1, 0.36, 1" ];

          animation = [
            "windows, 1, 3, custom"
            "windowsOut, 1, 3, custom, popin 80%"
            "border, 0, 10, custom"
            "borderangle, 0, 8, custom"
            "fade, 1, 3, custom"
            "workspaces, 1, 3, custom"
          ];
        };

        dwindle = {
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          pseudotile = "no"; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = "yes"; # you probably want this
        };

        gestures = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          workspace_swipe = true;
          workspace_swipe_fingers = 4;
        };

        binds.allow_workspace_cycles = "yes";

        plugin.hyprexpo = {
          columns = 3;
          gap_size = 15;
          workspace_method = "center current";

          enable_gesture = true;
          gesture_fingers = 4;
          gesture_distance = 300;
          gesture_positive = true;
        };

        plugin.scroller = {
          "col.selection_border" = selection;
          column_default_witdh = "onehalf";
          focus_wrap = false;
          gesture_workspace_switch_prefix = "e";
          center_row_if_space_available = true;
          jump_labels_color = active;
          jump_labels_keys = "sadjklewcmpgh";
        };

        windowrulev2 = [
          "opacity, 0.9, class:(Alacritty)"
          "opacity, 0.9, class:(kitty)"

          # this fixes bitwig studio
          # reference: https://github.com/hyprwm/Hyprland/issues/2034#issuecomment-1650278502
          "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"

          # no gaps when only one window on workspace
          # taken from: https://github.com/hyprwm/Hyprland/blob/3cec45d82113051d35e846e5d80719d8ea0f7002/example/hyprland.conf#L134-L145
          "bordersize 0, floating:0, onworkspace:w[tv1]"
          "rounding 0, floating:0, onworkspace:w[tv1]"
          "bordersize 0, floating:0, onworkspace:f[1]"
          "rounding 0, floating:0, onworkspace:f[1]"

          # set scroller column width to full screen if only window on workspace
          "plugin:scroller:columnwidth one, onworkspace:w[tv1]"
          "plugin:scroller:columnwidth one, onworkspace:f[1]"
        ];

        layerrule = [
          "blur, waybar"
          "ignorezero, waybar"
          "noanim, waybar"
        ];
      };
  };
}
