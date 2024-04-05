{ pkgs, ... }:
{
  imports = [
    ./gammastep.nix
    ./wofi.nix
  ];

  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    wl-clipboard
    xdg-utils
  ];

  home.sessionVariables = {
    # LIBSEAT_BACKEND = "seatd";
    QT_QPA_PLATFORM = "wayland";
  };

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
}
