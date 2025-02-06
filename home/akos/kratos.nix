{ lib, inputs, ... }:
let
  inherit (inputs.nix-colors) colorSchemes;
in
{
  imports = [
    ./global
    ./features/helix/full.nix
    ./features/shell/full.nix
    ./features/desktop/hyprland
    ./features/vscode.nix
    ./features/vscode-server.nix
    ./features/chromium.nix
    ./features/shell/azure.nix
    ./features/discord.nix
    ./features/linphone.nix
    ./features/darktable.nix
    ./features/onedrive.nix
  ];

  colorscheme = lib.mkDefault colorSchemes.equilibrium-dark;
  specialisation = {
    light.configuration.colorscheme = colorSchemes.equilibrium-light;
  };

  monitors = [
    {
      # Samsung
      name = "DP-2";
      model = "U28E850";
      width = 3840;
      height = 2160;
      scale = 1.5;
      x = 0;
      workspace = "1";
      primary = true;
    }
    {
      # Asus
      name = "HDMI-A-1";
      model = "ASUS VN247";
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
      "NVD_BACKEND,direct"
      "WLR_NO_HARDWARE_CURSORS,1"
      "MOZ_DISABLE_RDD_SANDBOX,1"
      "EGL_PLATFORM,wayland"
    ];
  };
}
