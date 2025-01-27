{ pkgs, config, inputs, lib, ... }:
let
  c = config.colorScheme.palette;
  toRGB = hex: builtins.concatStringsSep ", " (map toString (inputs.nix-colors.lib.conversions.hexToRGB hex));

  moduleBaseStyle = ''
    background-color: #${c.base02};
    padding: 0.125em 0.5em;
    margin: 0.125em 0.25em;
    border-radius: 1em;
  '';
in
{
  programs.waybar = {
    enable = true;
    settings.topbar = {
      layer = "top";
      position = "top";
      height = 30;
      modules-left = [
        "hyprland/submap"
        "hyprland/workspaces"
        "hyprland/window"
      ];
      modules-right = [
        "tray"
        "mpris"
        "pulseaudio"
        "hyprland/language"
        "battery"
        "clock"
      ];

      "hyprland/submap" = { };
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

      mpris = {
        format = "{player_icon}{status_icon}{dynamic}";
        dynamic-order = [ "artist" "title" ];
        dynamic-importance-order = [ "title" "artist" ];
        player-icons = {
          default = " ";
          spotify = " ";
        };
        status-icons = {
          paused = "  ";
          playing = "  ";
          stopped = "  ";
        };
      };

      "pulseaudio" = {
        format = "{icon} {volume}%";
        format-bluetooth = "󰂰 {icon} {volume}%";
        format-muted = " ";
        format-icons = {
          headphone = " ";
          hands-free = " ";
          headset = " ";
          phone = " ";
          portable = " ";
          car = "󰄍 ";
          default = " ";
        };
        on-click = "pavucontrol";
        on-scroll-up = "";
        on-scroll-down = "";
      };

      "hyprland/language" = {
        format-en = "󰌌  en";
        format-hu = "󰌌  hu";
      };

      battery = {
        interval = 10;
        format = "{icon} {capacity}%";
        format-icons = {
          charging = [ "󰢟 " "󰢜 " "󰂆 " "󰂇 " "󰂈 " "󰢝 " "󰂉 " "󰢞 " "󰂊 " "󰂋 " "󰂅 " ];
          discharging = [ "󰂎 " "󰁺 " "󰁻 " "󰁼 " "󰁽 " "󰁾 " "󰁿 " "󰂀 " "󰂁 " "󰂂 " "󰁹 " ];
        };
      };

      clock = {
        on-click = "swaync-client -t";
        format = "󰥔  {:%H:%M}";
        tooltip-format = "{:L%Y. %m. %d. %A}";
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
        transition: background-color 250ms ease-in-out;
      }
      window#waybar.solo > box {
        padding: 0.5em;
        background-color: #${c.base00};
      }
      window#waybar.solo.kitty > box {
        background-color: rgba(${toRGB c.base00}, 0.9);
      }

      #submap {
        background-color: #${c.base0D};
        color: #${c.base00};
        padding: 0.125em 0.5em;
        margin: 0.125em 0.25em;
        border-radius: 1em;
      }
      #workspaces button {
        background-color: #${c.base02};
        padding: 0.125em 0.375em;
        margin: 0.125em 0.25em;
        border-radius: 1em;
        color: #${c.base03};
      }
      #workspaces button.visible {
        background-color: #${c.base02};
        color: #${c.base0D};
      }
      #workspaces button.active {
        background-color: #${c.base0D};
        color: #${c.base00};
      }

      #window {
        ${moduleBaseStyle}
      }
      window#waybar.empty #window {
        background-color: rgba(0, 0, 0, 0.0);
      }

      #tray {
      	padding: 0.125em 0.25em;
      	margin: 0;
      }
      #tray > .active {
        background-color: #${c.base02};
        border-radius: 1em;
      }
      #tray > .active > image {
      	margin: 0 0.375em;
      }

      #mpris {
        ${moduleBaseStyle}
      }

      #pulseaudio {
        ${moduleBaseStyle}
      }
      #language {
        ${moduleBaseStyle}
      }
      #battery {
        ${moduleBaseStyle}
      }
      #clock {
        ${moduleBaseStyle}
      }
    '';
  };

  services.playerctld.enable = true;

  systemd.user.services.waybar = lib.mkForce {
    Unit = {
      PartOf = [ "graphical-session.target" ];
      After = "graphical-session-pre.target";
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      ExecStart = lib.getExe config.programs.waybar.package;
      ExecReload = "${pkgs.procps}/bin/kill -SIGUSR2 $MAINPID";
      Restart = "on-failure";
    };
  };
}
