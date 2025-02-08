{ lib, inputs, ... }:
let
  inherit (inputs.nix-colors) colorSchemes;
in
{
  imports = [
    ./global
    ./features/shell/full.nix
    ./features/helix/full.nix
    ./features/desktop/hyprland
    ./features/vscode.nix
    ./features/chromium.nix
    ./features/shell/azure.nix
    ./features/linphone.nix
    ./features/shell/iamb.nix
  ];

  colorscheme = lib.mkDefault colorSchemes.selenized-dark;
  specialisation = {
    light.configuration.colorscheme = colorSchemes.selenized-light;
  };

  services.blueman-applet.enable = true;

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
