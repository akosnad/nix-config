{ pkgs, config, ... }:
{
  imports = [
    ./gtk.nix
    ./edge.nix
    ./kitty.nix
    ./audio.nix
    ./mqtt-notify.nix
    ./yubikey-touch-detector.nix
    ./yubilock
    ./spotify.nix
    ./kde-connect.nix
    ./swaync.nix
    ./keepassxc.nix
  ];

  dconf.settings."org/gnome/desktop/interface".color-scheme =
    if config.lib.stylix.colors.variant == "dark" then "prefer-dark"
    else if config.lib.stylix.colors.variant == "light" then "prefer-light"
    else "default";


  xdg.portal.enable = true;
  xdg.autostart.enable = true;

  home.packages = with pkgs; [
    vlc
  ];
}
