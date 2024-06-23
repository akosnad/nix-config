{ pkgs, config, ... }:
let
  hypr-socket = "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock";
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";

  get-workspaces = pkgs.writeScript "get-workspaces" /* bash */ ''
    spaces_fix (){
        WORKSPACE_WINDOWS=$(${hyprctl} workspaces -j | ${pkgs.jq}/bin/jq 'map({key: .id | tostring, value: .windows}) | from_entries')
        seq 1 10 | ${pkgs.jq}/bin/jq --argjson windows "''${WORKSPACE_WINDOWS}" --slurp -Mc 'map(tostring) | map({id: ., windows: ($windows[.]//0)})'
    }

    spaces() {
      ${hyprctl} workspaces -j | jq -Mc 'map({id: .id, windows: .windows}) | sort_by(.id)'
    }

    spaces
    ${pkgs.socat}/bin/socat -u UNIX-CONNECT:${hypr-socket} - | while read -r line; do
        spaces
    done
  '';

  get-active-workspace = pkgs.writeScript "get-active-workspace" /* bash */ ''
    ${hyprctl} monitors -j | jq --raw-output .[0].activeWorkspace.id
    ${pkgs.socat}/bin/socat -u UNIX-CONNECT:${hypr-socket} - | ${pkgs.coreutils}/bin/stdbuf -o0 grep '^workspace>>' | ${pkgs.coreutils}/bin/stdbuf -o0 ${pkgs.gawk}/bin/awk -F '>>|,' '{print $2}'
  '';
in
pkgs.writeText "workspaces.yuck" /* yuck */ ''
  (defwidget workspaces []
    (box :space-evenly false
      (for workspace in workspaces
        (eventbox :onclick "${hyprctl} dispatch workspace ''${workspace.id}"
                  :onscroll "scripts/switch-workspace {}"
          (box :class "warning workspace-entry ''${workspace.windows > 0 ? "occupied" : "empty"} ''${active_workspace == workspace.id ? "current" : "inactive"}"
            (label :text "''${workspace.id}")
            )
          )
        )
      (workspace_fix)
      )
    )

    (deflisten workspaces :initial "[]"
      "${get-workspaces}")
    (deflisten active_workspace :initial "1"
      "${get-active-workspace}")

    (defwidget workspace_fix []
      (box :class "fix ''${active_workspace}"
           :visible false
      )
    )
''
