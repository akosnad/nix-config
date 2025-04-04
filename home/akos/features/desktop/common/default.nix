{ config, pkgs, ... }:
{
  imports = [
    ./fonts.nix
    ./gtk.nix
    ./edge.nix
    ./kitty
    ./audio.nix
    ./mqtt-notify.nix
    ./yubikey-touch-detector.nix
    ./yubilock.nix
    ./spotify.nix
    ./kde-connect.nix
    ./swaync.nix
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
