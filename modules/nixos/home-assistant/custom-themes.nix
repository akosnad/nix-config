{ pkgs, lib, config, ... }:
let
  inherit (lib) types literalExpression;
  cfg = config.services.home-assistant.customThemes;
in
{
  options.services.home-assistant.customThemes = lib.mkOption {
    type = types.listOf types.package;
    default = [ ];
    example = literalExpression ''
      with pkgs.home-assistant-custom-themes; [
        google
      ];
    '';
    description = ''
      List of custom themes to install.

      Themes are installed in the `themes` directory of the Home Assistant configuration directory.
      The `frontend` configuration section is automatically updated to include the custom themes.
    '';
  };

  config =
    let
      themesDir = pkgs.symlinkJoin {
        name = "home-assistant-custom-themes";
        paths = cfg;
      };
    in
    lib.mkIf (cfg != [ ]) {
      services.home-assistant.config = {
        frontend.themes = "!include_dir_merge_named ${themesDir}";
      };
    };
}
