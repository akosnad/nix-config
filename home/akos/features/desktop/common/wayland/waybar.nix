{ pkgs, config, inputs, lib, ... }:
let
  c = config.colorScheme.palette;
  toRGB = hex: builtins.concatStringsSep ", " (map toString (inputs.nix-colors.lib.conversions.hexToRGB hex));

  base = /* css */ ''
    background-color: #${c.base02};
    color: #${c.base06};
    padding: 0.125em 0.5em;
    margin: 0.125em 0.25em;
    border-radius: 1em;
    box-shadow: inset -1px -1px 2px rgba(0,0,0, 0.15);
  '';
  warning = /* css */ ''
    background-color: #${c.base0A};
    color: #${c.base00};
  '';
  error = /* css */ ''
    background-color: #${c.base08};
    color: #${c.base00};
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
    runtimeInputs = with pkgs; [ systemd libnotify ];
    # adapted from: https://github.com/guttermonk/yubilock/blob/main/scripts/yubilock-toggle.sh
    text = ''
      STATE_FILE="$HOME/.cache/yubilock-state"

      # Create state file if it doesn't exist
      if [ ! -f "$STATE_FILE" ]; then
          echo "off" > "$STATE_FILE"
      fi

      # Read current state
      current_state=$(cat "$STATE_FILE")

      # Toggle state
      sleep 1
      if [ "$current_state" = "on" ]; then
          # Turn off monitoring
          notify-send "Yubilock is shutting down" -e
          echo "off" > "$STATE_FILE"
          # Kill the monitoring process if it's running
          systemctl --user stop yubilock
          echo '{"text": "Yubilock: OFF", "class": "yubilock-off", "tooltip": "Yubilock disabled"}'
      else
          # Turn on monitoring
          echo "on" > "$STATE_FILE"
          # Start the monitoring script
          notify-send "Yubilock is now starting" -e
          systemctl --user start yubilock
          echo '{"text": "Yubilock: ON", "class": "yubilock-on", "tooltip": "Yubilock enabled"}'
      fi
    '';
  };
  yubilock-status = pkgs.writeShellApplication {
    name = "yubilock-status";
    runtimeInputs = with pkgs; [ usbutils systemd ];
    # adapted from: https://github.com/guttermonk/yubilock/blob/main/scripts/yubikey-status.sh
    text = ''
      STATE_FILE="$HOME/.cache/yubilock-state"

      # Create state file if it doesn't exist
      if [ ! -f "$STATE_FILE" ]; then
          echo "off" > "$STATE_FILE"
      fi

      # Read current state
      current_state=$(cat "$STATE_FILE")

      # Check if YubiKey is present
      if lsusb -d "1050:0407" > /dev/null; then
          yubikey_status="(inserted)"
          yubikey_class="inserted"
      else
          yubikey_status="(not present)"
          yubikey_class="not-present"
      fi

      # Output JSON for waybar
      if [ "$current_state" = "on" ]; then
          # Check if process is actually running
          if [[ "$(systemctl --user is-active yubilock.service)" == "active" ]]; then
              echo "{\"text\": \"Yubilock: ON $yubikey_status\", \"class\": \"yubilock-on-$yubikey_class\", \"tooltip\": \"Yubilock enabled $yubikey_status\", \"alt\": \"active\"}"
          else
              # Process died, update state
              echo "off" > "$STATE_FILE"
              echo "{\"text\": \"Yubilock: OFF $yubikey_status\", \"class\": \"yubilock-off-$yubikey_class\", \"tooltip\": \"YubiKey not present $yubikey_status\", \"alt\": \"inactive\"}"
          fi
      else
          echo "{\"text\": \"Yubilock: OFF $yubikey_status\", \"class\": \"yubilock-off-$yubikey_class\", \"tooltip\": \"Yubilock disabled $yubikey_status\", \"alt\": \"inactive\"}"
      fi
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
        interval = 5;
        exec = lib.getExe yubilock-status;
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
        background-color: #${c.base00};
      }
      window#waybar.solo.kitty > box {
        background-color: rgba(${toRGB c.base00}, 0.9);
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
        box-shadow: inset -1px -1px 2px rgba(0,0,0, 0.15);
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
        box-shadow: none;
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
      #custom-yubilock.yubilock-on-inserted {
        padding-right: 0.18em;
      }
      #custom-yubilock.yubilock-on-not-present {
        ${error}
        padding-right: 0.18em;
      }
      #custom-yubilock.yubilock-off-inserted {
        ${warning}
      }
      #custom-yubilock.yubilock-off-not-present {
        ${error}
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
