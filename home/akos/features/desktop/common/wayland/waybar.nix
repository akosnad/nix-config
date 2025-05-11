{ pkgs, config, lib, ... }:
let
  base = /* css */ ''
    background-color: @base02;
    color: @base06;
    padding: 0.125em 0.5em;
    margin: 0.125em 0.25em;
    border-radius: 1em;
    box-shadow: inset -1px -1px 2px rgba(0,0,0, 0.15);
  '';
  warning = /* css */ ''
    background-color: @base0A;
    color: @base00;
  '';
  error = /* css */ ''
    background-color: @base08;
    color: @base00;
  '';

  scrollerModeSignal = 8;
  scrollerModeFile = "$XDG_RUNTIME_DIR/scroller-mode";
  scroller-mode-listener = pkgs.writeShellApplication {
    name = "scroller-mode-listener";
    runtimeInputs = with pkgs; [ socat jq procps ];
    text = ''
      handle() {
        if [[ ''${1:0:8} != "scroller" ]]; then
          return
        fi

        if [[ ''${1:10:9} == "mode, row" ]]; then
          echo '${builtins.toJSON { text=" "; percentage=0; class="mode-row"; }}' > "${scrollerModeFile}"
        elif [[ ''${1:10:12} == "mode, column" ]]; then
          echo '${builtins.toJSON { text=""; percentage=100; class="mode-col"; }}' > "${scrollerModeFile}"
        fi

        pkill -SIGRTMIN+${toString scrollerModeSignal} waybar # update widget on waybar
      }
      echo '${builtins.toJSON { text=" "; percentage=0; class="mode-row"; }}' > "${scrollerModeFile}"
      socat -u "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while read -r line; do handle "$line"; done
    '';
  };

  yubilock-toggle = pkgs.writeShellApplication {
    name = "yubilock-toggle";
    runtimeInputs = with pkgs; [ socat ];
    text = ''
      echo "toggle" | socat - UNIX-CONNECT:"$XDG_RUNTIME_DIR/yubilock.sock"
    '';
  };
  yubilock-state = pkgs.writeShellApplication {
    name = "yubilock-state";
    runtimeInputs = with pkgs; [ socat ];
    text = ''
      stdbuf -i0 -o0 -e0 socat -u UNIX-CONNECT:"$XDG_RUNTIME_DIR"/yubilock.sock -
    '';
  };
in
{
  programs.waybar = {
    enable = true;
    settings.topbar = {
      layer = "top";
      position = "top";
      height = 30;
      modules-left = [
        "custom/scroller-mode"
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
        "custom/yubilock"
      ];

      "custom/scroller-mode" = {
        # adapted from: https://github.com/dawsers/hyprscroller/issues/57#issuecomment-2418305146
        exec = lib.getExe (pkgs.writeShellScriptBin "scroller-mode-reader" "cat \"${scrollerModeFile}\"\n");
        return-type = "json";
        interval = "once";
        signal = 8;
        on-click = "hyprctl dispatch submap reset && pkill -SIGRTMIN+8 waybar";
      };
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

      network = rec {
        on-click = "${lib.getExe' pkgs.networkmanagerapplet "nm-connection-editor"}";
        format = "{icon}";
        format-wifi = "{icon} {essid}";
        tooltip-format-wifi = builtins.concatStringsSep "\n"
          ([ "󱄙 {frequency} GHz 󰹤 {signaldBm} dBm ({signalStrength}%)" ]
            ++ [ tooltip-format-ethernet ]);
        tooltip-format-ethernet = builtins.concatStringsSep "\n" [
          "󰩟 {ipaddr}/{cidr}"
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
      "custom/yubilock" = {
        return-type = "json";
        exec = lib.getExe yubilock-state;
        on-click = lib.getExe yubilock-toggle;
        tooltip = true;
        format = "{icon}";
        format-icons = {
          active = " ";
          inactive = " ";
        };
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

      /* disabled until we can somehow have hyprscroller updated (to at least https://github.com/dawsers/hyprscroller/commit/1b40d06071496e121bdaf6df1900cc1a07310db7) */
      /*
      window#waybar.solo > box {
        padding: 0.5em;
        background-color: @base00;
      }
      window#waybar.solo.kitty > box {
        background-color: alpha(@base00, 0.9);
      }
      */

      #custom-scroller-mode {
        ${base}
      }
      #custom-scroller-mode.mode-row {
        /* removes right offset introduced by the space character after the wider nerd font */
        padding-right: 0.325em;
      }
      #submap {
        background-color: @base0D;
        color: @base00;
        padding: 0.125em 0.5em;
        margin: 0.125em 0.25em;
        border-radius: 1em;
      }
      #workspaces button {
        background-color: @base02;
        padding: 0.125em 0.375em;
        margin: 0.125em 0.25em;
        border-radius: 1em;
        color: @base03;
        box-shadow: inset -1px -1px 2px rgba(0,0,0, 0.15);
      }
      #workspaces button.visible {
        background-color: @base02;
        color: @base0D;
      }
      #workspaces button.active {
        background-color: @base0D;
        color: @base00;
      }

      #window {
        ${base}
      }
      window#waybar.empty #window {
        background-color: rgba(0, 0, 0, 0.0);
        box-shadow: none;
      }

      #tray {
      	padding: 0.125em 0.25em;
      	margin: 0;
        color: @base03;
      }
      #tray > .active {
        background-color: @base02;
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
      #network.disconnected, #network.ethernet {
        /* removes right offset from icon without text */
        padding-right: 0.0375em;
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

      #custom-yubilock {
        ${base}
      }
      #custom-yubilock.yubilock-locked-connected {
        padding-right: 0.18em;
      }
      #custom-yubilock.yubilock-locked-disconnected {
        ${error}
        padding-right: 0.18em;
      }
      #custom-yubilock.yubilock-unlocked-connected {
        ${warning}
      }
      #custom-yubilock.yubilock-unlocked-disconnected {
        ${error}
      }
    '';
  };

  stylix.targets.waybar.addCss = false;

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

  systemd.user.services.scroller-mode-listener = {
    Unit = {
      Before = "waybar.service";
      PartOf = [ "graphical-session.target" ];
      After = "graphical-session-pre.target";
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      ExecStart = lib.getExe scroller-mode-listener;
      Restart = "on-failure";
      RestartSec = "1s";
    };
  };
}
