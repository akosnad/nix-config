{ lib, ... }:
let
  inherit (lib)
    mkOption
    types
    mkOverride
    pipe
    nameValuePair
    listToAttrs
    ;
in
{
  config.flake.modules.homeManager.base = { config, ... }:
    let
      cfg = config.programs.niri;
    in
    {
      options = {
        programs.niri = {
          enable = mkOption {
            type = types.bool;
            default = false;
          };
        };
      };

      config = {
        xdg.configFile.niri-config.enable = mkOverride 50 cfg.enable;

        programs.niri.settings = {
          outputs =
            let
              mkOutput =
                m: with m; if !enabled then { enable = false; } else {
                  enable = enabled;
                  focus-at-startup = primary;
                  mode = {
                    inherit width height;
                    refresh = refreshRate;
                  };
                  position = {
                    inherit x y;
                  };
                  inherit scale;
                  variable-refresh-rate = if vrr != null then vrr != 0 else false;
                };
            in
            pipe config.monitors [
              (map (m: nameValuePair m.name (mkOutput m)))
              listToAttrs
            ];
        };
      };
    };

  config.flake.modules.nixos.desktop = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };
    niri-flake = {
      cache.enable = false;
    };

    environment.etc."greetd/environments".text = "niri-session";
  };

  config.flake.modules.homeManager.desktop = { pkgs, lib, config, ... }: {
    xdg.portal.configPackages = [ config.programs.niri.package ];
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];

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

        cursor = {
          hide-after-inactive-ms = 1000;
          size = 24;
          theme = "Quintom_Ink";
        };

        layout = {
          border.enable = false;
          focus-ring.enable = false;
          shadow.enable = true;
        };
        prefer-no-csd = true;

        window-rules = [
          {
            matches = [ ];
            geometry-corner-radius = let x = 12.0; in {
              bottom-left = x;
              bottom-right = x;
              top-left = x;
              top-right = x;
            };
            clip-to-geometry = true;
          }
        ];


        binds = {
          "Mod+Shift+slash".action.show-hotkey-overlay = { };

          # spawn hotkeys
          "Mod+Return".action.spawn = "kitty";
          "Mod+Q".action.spawn = "microsoft-edge";
          "Mod+E".action.spawn = "nautilus";
          "Mod+F".action.toggle-window-floating = { };
          "Menu".action.spawn = "wofi-launch";
          "Mod+Menu".action.spawn = "comma-gui";
          "Mod+Backspace".action.spawn = "toggle-theme";
          "Mod+N".action.spawn = [ "swaync-client" "-t" ];
          "Mod+G".action.spawn = "toggle-gammastep";
          "Mod+D".action.spawn = [ "hyprlock" "--immediate" ];
          "Mod+W".action.spawn = "cycle-wallpaper";

          # overview, layout manipulation
          "Alt+Space".action.toggle-overview = { };
          "Mod+Space".action.toggle-column-tabbed-display = { };
          "Mod+F11".action.fullscreen-window = { };
          "Mod+equal".action.switch-preset-column-width = { };
          "Mod+minus".action.switch-preset-column-width-back = { };

          # window and column manipulation
          "Mod+Escape".action.close-window = { };
          "Mod+Shift+Escape".action.quit = { };
          "Mod+Shift+Up".action.move-window-to-workspace-up = { };
          "Mod+Shift+K".action.move-window-to-workspace-up = { };
          "Mod+Shift+Down".action.move-window-to-workspace-down = { };
          "Mod+Shift+J".action.move-window-to-workspace-down = { };
          "Mod+C".action.maximize-column = { };

          # window and column navigation
          "Mod+Left".action.focus-column-left = { };
          "Mod+H".action.focus-column-left = { };
          "Mod+Right".action.focus-column-right = { };
          "Mod+L".action.focus-column-right = { };
          "Mod+Up".action.focus-window-up = { };
          "Mod+K".action.focus-window-up = { };
          "Mod+Down".action.focus-window-down = { };
          "Mod+J".action.focus-window-down = { };

          # workspace navigation
          "Mod+Ctrl+Up".action.focus-workspace-up = { };
          "Mod+Ctrl+K".action.focus-workspace-up = { };
          "Mod+Ctrl+Down".action.focus-workspace-down = { };
          "Mod+Ctrl+J".action.focus-workspace-down = { };
          "Mod+WheelScrollDown" = {
            cooldown-ms = 150;
            action.focus-workspace-down = { };
          };
          "Mod+WheelScrollUp" = {
            cooldown-ms = 150;
            action.focus-workspace-up = { };
          };

          # workspace manipulation
          "Mod+Alt+Left".action.move-workspace-to-monitor-left = { };
          "Mod+Alt+H".action.move-workspace-to-monitor-left = { };
          "Mod+Alt+Right".action.move-workspace-to-monitor-right = { };
          "Mod+Alt+L".action.move-workspace-to-monitor-right = { };
          "Mod+Alt+Up".action.move-workspace-to-monitor-up = { };
          "Mod+Alt+K".action.move-workspace-to-monitor-up = { };
          "Mod+Alt+Down".action.move-workspace-to-monitor-down = { };
          "Mod+Alt+J".action.move-workspace-to-monitor-down = { };

          # monitor navigation
          "Mod+Ctrl+Left".action.focus-monitor-left = { };
          "Mod+Ctrl+H".action.focus-monitor-left = { };
          "Mod+Ctrl+Right".action.focus-monitor-right = { };
          "Mod+Ctrl+L".action.focus-monitor-right = { };

          # media
          "Mod+KP_Left".action.spawn = [ (lib.getExe pkgs.playerctl) "previous" ];
          "Mod+KP_Begin".action.spawn = [ (lib.getExe pkgs.playerctl) "play-pause" ];
          "Mod+KP_Right".action.spawn = [ (lib.getExe pkgs.playerctl) "next" ];
          "XF86AudioPlay".action.spawn = [ (lib.getExe pkgs.playerctl) "play-pause" ];
          "XF86AudioPause".action.spawn = [ (lib.getExe pkgs.playerctl) "play-pause" ];
          "XF86AudioMute".action.spawn = [ (lib.getExe pkgs.pamixer) "-t" ];
          "XF86AudioRaiseVolume".action.spawn = [ (lib.getExe pkgs.pamixer) "-i" "5" ];
          "XF86AudioLowerVolume".action.spawn = [ (lib.getExe pkgs.pamixer) "-d" "5" ];

          # screen brightness
          "XF86MonBrightnessUp".action.spawn = [ (lib.getExe pkgs.light) "-A" "5" ];
          "XF86MonBrightnessDown".action.spawn = [ (lib.getExe pkgs.light) "-U" "5" ];
        };
      };
    };
  };
}
