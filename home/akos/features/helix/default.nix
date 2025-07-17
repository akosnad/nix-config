{ pkgs, lib, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      editor = {
        line-number = "relative";
        inline-diagnostics = {
          cursor-line = "warning";
          other-lines = "warning";
          max-diagnostics = 5;
        };
      };
      keys.normal = {
        space.w = ":w";
        space.q = ":q";
        space.space = ":format";
        esc = [ "collapse_selection" "keep_primary_selection" ];
      };
    };
  };

  xdg.configFile =
    let
      reloadHelix = lib.getExe (pkgs.writeShellApplication {
        name = "reload-helix";
        runtimeInputs = with pkgs; [ util-linux procps ];
        bashOptions = [ ];
        text = ''
          pids="$(pidof hx)"
          if [[ "$pids" != "" ]]; then
            xargs kill -USR1 <<<"$pids"
          fi
        '';
      });
    in
    {
      "helix/config.toml".onChange = reloadHelix;
      "helix/themes/stylix.toml".onChange = reloadHelix;
    };
}
