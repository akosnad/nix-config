{ pkgs, ... }:
{
  imports = [
    ./gammastep.nix
    ./wofi.nix
    ./eww
    ./hyprlock.nix
    ./hypridle.nix
    ./waypipe.nix
  ];

  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    wl-clipboard
    xdg-utils
  ];

  home.sessionVariables = {
    # LIBSEAT_BACKEND = "seatd";
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL = "1";
  };

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
}
