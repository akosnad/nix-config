{ config, pkgs, ... }:
{
  imports = [
    ./fonts.nix
    ./gtk.nix
    ./firefox.nix
    ./kitty
    ./audio.nix
    ./mqtt-notify.nix
    ./yubikey-touch-detector.nix
    ./spotify.nix
    ./kde-connect.nix
  ];

  dconf.settings."org/gnome/desktop/interface".color-scheme =
    if config.colorscheme.variant == "dark" then "prefer-dark"
    else if config.colorscheme.variant == "light" then "prefer-light"
    else "default";


  xdg.portal.enable = true;

  home.packages = with pkgs; [
    vlc
  ];
}
