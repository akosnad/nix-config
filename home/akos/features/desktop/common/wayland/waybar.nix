{ config, ... }:
let
  c = config.colorScheme.palette;
in
{
  programs.waybar = {
    enable = true;
    settings.topbar = {
      layer = "top";
      position = "top";
      height = 30;
      spacing = 8;
      modules-left = [
        "hyprland/workspaces"
        "hyprland/window"
      ];
      modules-right = [
        "tray"
        "clock"
      ];

      "hyprland/workspaces" = { };
      "hyprland/window" = {
        separate-outputs = true;
        icon = true;
        icon-size = 16;
      };

      tray = {
        icon-size = 16;
        spacing = 8;
      };
      clock = {
        on-click = "swaync-client -t";
        tooltip = false;
      };
    };

    style = /* css */ ''
      * {
        border: none;
      }
      window#waybar {
        background-color: rgba(0, 0, 0, 0.0);
        border: none;
        box-shadow: none;
        padding: 0.25em 2em;
      }
      window#waybar.solo {
        background-color: #${c.base00};
      }

      #workspaces button {
        background-color: #${c.base02};
        color: #${c.base03};
        padding: 0.125em 0.375em;
        margin: 0.125em;
        border-radius: 1em;
      }

      #workspaces button.visible {
        background-color: #${c.base02};
        color: #${c.base0D};
      }
      #workspaces button.active {
        background-color: #${c.base0D};
        color: #${c.base00};
      }

      #clock {
        background-color: #${c.base02};
        padding: 0.125em 0.375em;
        margin: 0.125em;
        border-radius: 1em;
      }
      #window {
        background-color: #${c.base02};
        padding: 0.125em 0.375em;
        margin: 0.125em;
        border-radius: 1em;
      }
    '';
  };
}
