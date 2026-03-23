{ lib, config, ... }:
let
  inherit (lib) mkOption types mkOverride;
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
  };
}
