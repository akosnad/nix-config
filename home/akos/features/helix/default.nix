{ pkgs, lib, ... }:
{
  imports = [
    ./theme.nix
  ];

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      editor = {
        line-number = "relative";
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
      "helix/themes/base16.toml".onChange = reloadHelix;
    };
}
