{ config, ... }:
{
  imports = [
    ./firefox.nix
  ];

  dconf.settings."org/gnome/desktop/interface".color-scheme = 
    if config.colorscheme.variant == "dark" then "prefer-dark"
    else if config.colorscheme.variant == "light" then "prefer-light"
    else "default";

  xdg.portal.enable = true;
}
