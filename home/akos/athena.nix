{ lib, inputs, ... }:
let
  inherit (inputs.nix-colors) colorSchemes;
in
{
  imports = [
    ./global
    ./features/nvim/full.nix
    ./features/desktop/hyprland
    ./features/vscode.nix
    ./features/chromium.nix
    ./features/shell/azure.nix
  ];

  colorscheme = lib.mkDefault colorSchemes.atelier-forest;
  specialisation = {
    light.configuration.colorscheme = colorSchemes.atelier-forest-light;
  };

  monitors = [
    {
      name = "eDP-1";
      model = "0x0555";
      width = 1536;
      height = 1024;
      scale = 1.0;
      x = 0;
      workspace = "1";
      primary = true;
    }
  ];
}
