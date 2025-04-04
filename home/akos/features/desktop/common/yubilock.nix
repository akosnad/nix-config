{ pkgs, lib, config, ... }:
let
  yubilock = pkgs.writeShellApplication {
    name = "yubilock";
    runtimeInputs = with pkgs; [ usbutils gnugrep ];
    # adapted from: https://github.com/guttermonk/yubilock/blob/main/scripts/yubilock.sh
    text = ''
      STATE_FILE="$HOME/.cache/yubilock-state"

      # Function to check if our YubiKey is currently plugged in
      check_yubikey() {
          if lsusb -d "1050:0407" > /dev/null; then
              return 0 # device is present
          else
              return 1 # device is not present
          fi
      }

      # Function to lock the screen
      lock_screen() {
          # You can replace this with your preferred screen locking command
          # Examples:
          # gnome-screensaver-command -l  # For GNOME
          # loginctl lock-session         # systemd-based systems
          # xscreensaver-command -lock    # For xscreensaver
          # i3lock                        # For i3

          ${lib.getExe config.programs.hyprlock.package} --immediate
          echo "Screen locked at $(date)"
      }

      # Create state file if it doesn't exist
      if [ ! -f "$STATE_FILE" ]; then
          echo "off" > "$STATE_FILE"
      fi

      # Main monitoring loop
      echo "YubiKey monitoring started at $(date)"

      while true; do
          # Check if monitoring is still enabled
          if [ "$(cat "$STATE_FILE")" != "on" ]; then
              echo "YubiKey monitoring stopped at $(date)"
              exit 0
          fi

          if check_yubikey; then
              echo "YubiKey detected at $(date)"

              # Wait until the YubiKey is removed
              while check_yubikey && [ "$(cat "$STATE_FILE")" = "on" ]; do
                  sleep 1
              done

              # If we exited because service was disabled, exit gracefully
              if [ "$(cat "$STATE_FILE")" != "on" ]; then
                  echo "YubiKey monitoring stopped at $(date)"
                  exit 0
              fi

              echo "YubiKey removed at $(date)"
              lock_screen
          else
              echo "No YubiKey detected. Checking again in 10 seconds..."
              # Check less frequently to reduce system load
              sleep 10
          fi
      done
    '';
  };
in
{
  systemd.user.services.yubilock = {
    Unit.Description = "Yubilock";
    Service = {
      ExecStart = "${lib.getExe yubilock}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
