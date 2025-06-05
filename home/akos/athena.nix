{ pkgs, ... }:
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
    ./features/kicad.nix
  ];

  specialisation.light.configuration.stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/selenized-light.yaml";

  services.blueman-applet.enable = true;

  wayland.windowManager.hyprland.settings = {
    input.touchpad = {
      scroll_factor = 0.15;
    };
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
