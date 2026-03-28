{ lib, config, ... }:
let
  inherit (lib)
    mkOption
    types
    mkOverride
    pipe
    nameValuePair
    listToAttrs
    ;
  cfg = config.programs.niri;
in
{
  options = {
    programs.niri = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = {
    xdg.configFile.niri-config.enable = mkOverride 50 cfg.enable;

    programs.niri.settings = {
      outputs =
        let
          mkOutput =
            m: with m; if !enabled then { enable = false; } else {
              enable = enabled;
              focus-at-startup = primary;
              mode = {
                inherit width height;
                refresh = refreshRate;
              };
              position = {
                inherit x y;
              };
              inherit scale;
              variable-refresh-rate = if vrr != null then vrr != 0 else false;
            };
        in
        pipe config.monitors [
          (map (m: nameValuePair m.name (mkOutput m)))
          listToAttrs
        ];
    };
  };
}
