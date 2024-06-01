{ lib, inputs, ... }:
let
  inherit (inputs.nix-colors) colorSchemes;
in
{
  imports = [
    ./global
    ./features/desktop/hyprland
    ./features/vscode.nix
    ./features/chromium.nix
  ];

  colorscheme = lib.mkDefault colorSchemes.atelier-forest;
  specialisation = {
    light.configuration.colorscheme = colorSchemes.atelier-forest-light;
  };

  monitors = [
    {
      name = "eDP-1";
      width = 1536;
      height = 1024;
      scale = 1.0;
      x = 0;
      workspace = "1";
      primary = true;
    }
  ];

  wallpaper = "${./features/desktop/wallpapers/bliss_graded_16_9.jpg}";
}
