{ pkgs, lib, ... }:
let
  detector-socket = "\"$XDG_RUNTIME_DIR\"/yubikey-touch-detector.socket";
  securitykeyListener = pkgs.writeShellApplication {
    name = "securitykey-listener";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      gnugrep
      socat
      eww
    ];
    text = ''
      socat -u UNIX-CONNECT:${detector-socket} - | while read -r -n5 state; do
        category="$(cut -d_ -f1 <<< "$state")"
        state="$(cut -d_ -f2 <<< "$state")"
        eww update securitykey_text="$category "
        echo "$state"
      done
    '';
  };
in
pkgs.writeText "securitykey.yuck" /* yuck */ ''
  (defwidget securitykey []
    (box
      (revealer :transition "none"
                :reveal {securitykey_status != "0"}
        (box :class "securitykey"
          (label :text securitykey_text)
        )
      )
      (gap)
    )
  )
  (deflisten securitykey_status :initial "0"
    "${lib.getExe securitykeyListener}")
  (defvar securitykey_text "")
''
