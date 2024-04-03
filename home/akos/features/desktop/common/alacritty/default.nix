{ pkgs, config, ... }:
let
  fontFamily = "Terminus";
  colors = pkgs.writeText "alacritty-colors.toml" (import ./colors.nix config.colorScheme);
in
{
  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
    settings = {
      import = [ colors ];
      font = {
        size = 11.0;
        normal.family = fontFamily;
        bold.family = fontFamily;
        bold.style = "Bold";
        italic.family = fontFamily;
        italic.style = "Italic";
        bold_italic.family = fontFamily;
        bold_italic.style = "Bold Italic";
      };
      window.padding = {
        x = 8;
        y = 8;
      };
    };
  };
}
