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

  monitors = [
    {
      # Samsung
      name = "DP-2";
      width = 3840;
      height = 2160;
      scale = 1.5;
      x = 0;
      workspace = "1";
      primary = true;
    }
    {
      # Asus
      name = "DVI-I-1";
      width = 1920;
      height = 1080;
      x = -1920;
      workspace = "2";
    }
    {
      name = "Unknown-1";
      enabled = false;
    }
  ];

  wayland.windowManager.hyprland.settings = {
    env = [
      "LIBVA_DRIVER_NAME,nvidia"
      "XDG_SESSION_TYPE,wayland"
      "GBM_BACKEND,nvidia-drm"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      "WLR_NO_HARDWARE_CURSORS,1"
    ];
  };

  wallpaper = "${./features/desktop/wallpapers/bliss_graded_16_9.jpg}";
}
