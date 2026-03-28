{ pkgs, ... }:
let
  inherit (pkgs) writeShellScriptBin writeShellApplication;
in
{
  home.packages = [
    (writeShellScriptBin "wofi-launch" ''
      # if wofi is running, close it
      if [ $(pgrep wofi) ]; then
          kill $(pidof wofi)
      # if not running, launch it
      else
          export QT_QPA_PLATFORM="wayland"
          export NIXOS_OZONE_WL="1"
          exec wofi --show drun,run
      fi
    '')

    (writeShellScriptBin "cycle-wallpaper" ''
      systemctl --user --wait start wallpaper.service
    '')

    (writeShellScriptBin "toggle-gammastep" ''
      state="$(systemctl is-active --user gammastep)"

      # if gammastep service is running, stop it

      if [[ "$state" == "deactivating" ]]; then
          exit 0
      fi

      if [[ "$state" == "active" ]]; then
          notify-send -t 3000 -e 'Gammastep' 'Gammastep is now disabled'
          systemctl --user stop gammastep
      # if not running, start it
      else
          systemctl --user start gammastep
          notify-send -t 3000 -e 'Gammastep' 'Gammastep is now enabled'
      fi
    '')

    (writeShellApplication {
      name = "comma-gui-picker";
      runtimeInputs = [ pkgs.zenity ];
      text = ''
        zenity --list --title="Launch GUI app" --text="Selech which package to use:" --column="Derivation outputs"
      '';
    })

    (writeShellApplication {
      name = "comma-gui-progress";
      runtimeInputs = with pkgs; [
        zenity
        gawk
        coreutils
      ];
      text = ''
        fifo="$(mktemp -u)"
        mkfifo "$fifo"
        cleanup() {
          rm "$fifo"
        }
        trap cleanup EXIT

        zenity --progress --auto-close --title="Launching $1..." --pulsate --text="Preparing..." <"$fifo" &
        pid="$!"

        tee >(awk '{print "# " $0; fflush()}' >"$fifo")

        wait "$pid"
      '';
    })

    (writeShellApplication {
      name = "comma-gui";
      runtimeInputs = with pkgs; [
        zenity
        coreutils
        comma
      ];
      text = ''
        target="$(zenity --entry --title="Launch GUI app" --text="Enter binary name:")"

        stdout="$(mktemp)"
        stderr="$(mktemp)"
        cleanup() {
          rm -f "$stdout" "$stderr"
        }
        trap cleanup EXIT

        ( ( (comma -P "comma-gui-picker" -x "$target" 3>&2 2>&1 1>&3) | "comma-gui-progress" "$target") 1>"$stderr" 2>"$stdout") &

        wait < <(jobs -p)

        bin="$(cat "$stdout")"
        if [[ $bin == "" ]]; then
          err="$(tail -n10 "$stderr")"
          zenity --error --title="Launch GUI app failed" --text="$err"
          exit 1
        fi

        </dev/null "$bin" &>/dev/null &
        disown
      '';
    })
  ];
}
