{ pkgs, config, inputs, lib, ... }:
let
  c = config.colorScheme.palette;
  toRGB = hex: builtins.concatStringsSep ", " (map toString (inputs.nix-colors.lib.conversions.hexToRGB hex));

  base = /* css */ ''
    background-color: #${c.base02};
    padding: 0.125em 0.5em;
    margin: 0.125em 0.25em;
    border-radius: 1em;
  '';
  warning = /* css */ ''
    background-color: #${c.base0A};
    color: #${c.base00};
  '';
  error = /* css */ ''
    background-color: #${c.base08};
    color: #${c.base00};
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
        "network"
        "upower"
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
        dynamic-len = 20;
        title-len = 15;
        artist-len = 15;
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
        on-click = "${lib.getExe pkgs.pamixer} -t";
        on-click-right = "pavucontrol";
        on-scroll-up = "${lib.getExe pkgs.pamixer} -i 5";
        on-scroll-down = "${lib.getExe pkgs.pamixer} -d 5";
      };

      "hyprland/language" = {
        format-en = "󰌌  en";
        format-hu = "󰌌  hu";
      };

      network = {
        on-click = "${lib.getExe' pkgs.networkmanagerapplet "nm-connection-editor"}";
        format = "{icon}";
        format-wifi = "{icon} {essid}";
        tooltip-format-wifi = builtins.concatStringsSep "\n" [
          "󰩟 {ipaddr}/{cidr}"
          "󱄙 {frequency} GHz 󰹤 {signaldBm} dBm ({signalStrength}%)"
          " {bandwidthUpBits}"
          " {bandwidthDownBits}"
        ];
        format-icons = {
          ethernet = "󰛳 ";
          wifi = [ "󰤯 " "󰤟 " "󰤢 " "󰤥 " "󰤨 " ];
          disconnected = "󰱟 ";
        };
      };

      upower = {
        # Nothing Ear (a)
        native-path = "/org/bluez/hci0/dev_2C_BE_EB_D3_EE_13";
        icon-size = 16;
        show-icon = false;
        hide-if-empty = true;
        format = "󰥉 {percentage}";
      };

      battery = {
        interval = 10;
        format = "{icon} {capacity}%";
        format-icons = {
          charging = [ "󰢟 " "󰢜 " "󰂆 " "󰂇 " "󰂈 " "󰢝 " "󰂉 " "󰢞 " "󰂊 " "󰂋 " "󰂅 " ];
          discharging = [ "󰂎 " "󰁺 " "󰁻 " "󰁼 " "󰁽 " "󰁾 " "󰁿 " "󰂀 " "󰂁 " "󰂂 " "󰁹 " ];
        };
        states = {
          warning = 30;
          critical = 10;
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
        transition: background-color 250ms cubic-bezier(0.22, 1, 0.36, 1);
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
        ${base}
      }
      window#waybar.empty #window {
        background-color: rgba(0, 0, 0, 0.0);
      }

      #tray {
      	padding: 0.125em 0.25em;
      	margin: 0;
        color: #${c.base03};
      }
      #tray > .active {
        background-color: #${c.base02};
        border-radius: 1em;
      }
      #tray > .active > image {
      	margin: 0 0.375em;
      }

      #mpris {
        ${base}
      }

      #pulseaudio {
        ${base}
      }
      #language {
        ${base}
      }

      #network {
        ${base}
      }
      #network.linked {
        ${warning}
      }
      #network.disconnected {
        ${error}
      }

      #upower {
        ${base}
      }

      #battery {
        ${base}
      }
      #battery.discharging.warning {
        ${warning}
      }
      #battery.discharging.critical {
        ${error}
      }

      #clock {
        ${base}
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
