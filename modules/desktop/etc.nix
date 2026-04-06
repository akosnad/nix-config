{ lib, ... }:
{
  config.flake.modules.homeManager.desktop = { pkgs, config, ... }:
    {
      dconf.settings."org/gnome/desktop/interface".color-scheme =
        if config.lib.stylix.colors.variant == "dark" then lib.mkForce "prefer-dark"
        else if config.lib.stylix.colors.variant == "light" then lib.mkForce "prefer-light"
        else "default";

      xdg.portal.enable = true;
      xdg.autostart.enable = true;

      home.packages = with pkgs; [
        vlc
        ksnip
      ];
    };
}
