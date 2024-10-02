{ pkgs, config, lib, ... }:
let
  hypr-socket = "\"$XDG_RUNTIME_DIR\"/hypr/\"$HYPRLAND_INSTANCE_SIGNATURE\"/.socket2.sock";
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";

  get-workspaces = pkgs.writeShellApplication {
    name = "get-workspaces";
    runtimeInputs = with pkgs; [ jq socat ]
      ++ [ config.wayland.windowManager.hyprland.package ];
    text = /* bash */ ''
      spaces() {
        workspaces="$(hyprctl workspaces -j | jq -Mc 'map({id: .id, windows: .windows}) | sort_by(.id)')"
        active_workspaces="$(hyprctl monitors -j | jq -Mc 'map(.activeWorkspace.id)')"
        current_workspace="$(hyprctl monitors -j | jq -Mc '.[] | select(.focused) | .activeWorkspace.id')"
        jq -Mc --argjson active_workspaces "''${active_workspaces}" \
          --argjson current_workspace "''${current_workspace}" \
          'map(. | .active = (any($active_workspaces[] == .id; .)) | .current = (.id == $current_workspace))' <<< "$workspaces"
      }

      spaces
      socat -u UNIX-CONNECT:${hypr-socket} - | while read -r; do
          spaces
      done
    '';
  };
in
pkgs.writeText "workspaces.yuck" /* yuck */ ''
  (defwidget workspaces []
    (box :space-evenly false
      (for workspace in workspaces
        (eventbox :onclick "${hyprctl} dispatch workspace ''${workspace.id}"
                  :onscroll "scripts/switch-workspace {}"
          (box :class "warning workspace-entry ''${workspace.windows > 0 ? "occupied" : "empty"} ''${workspace.active ? workspace.current ? "current" : "active" : "inactive"}"
            (label :text "''${workspace.id}")
            )
          )
        )
      )
    )

    (deflisten workspaces :initial "[]"
      "${lib.getExe get-workspaces}")
''
