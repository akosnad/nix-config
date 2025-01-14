{ config, inputs, ... }:
let
  c = config.colorScheme.palette;
  toRGB = hex: builtins.concatStringsSep ", " (map toString (inputs.nix-colors.lib.conversions.hexToRGB hex));
in
{
  programs.waybar = {
    enable = true;
    settings.topbar = {
      layer = "top";
      position = "top";
      height = 30;
      modules-left = [
        "hyprland/workspaces"
        "hyprland/window"
      ];
      modules-right = [
        "hyprland/language"
        "tray"
        "clock"
      ];

      "hyprland/workspaces" = { };
      "hyprland/window" = {
        separate-outputs = true;
        icon = true;
        icon-size = 16;
      };

      "hyprland/language" = {
        format-en = "en";
        format-hu = "hu";
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
      }
      window#waybar > box {
        padding: 0.5em 0.5em 0 0.5em;
        background-color: rgba(0, 0, 0, 0.0);
      }
      window#waybar.solo > box {
        padding: 0.5em;
        background-color: #${c.base00};
      }
      window#waybar.solo.kitty > box {
        background-color: rgba(${toRGB c.base00}, 0.9);
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

      #language {
        background-color: #${c.base02};
        padding: 0.125em 0.375em;
        margin: 0.125em;
        border-radius: 1em;
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
      window#waybar.empty #window {
        background-color: rgba(0, 0, 0, 0.0);
      }
    '';
  };
}
