{ pkgs, lib, config, ... }:
{
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = lib.mkDefault "Quintom_Ink";
      package = pkgs.quintom-cursor-theme;
    };
  };

  specialisation = {
    dark.configuration.gtk.cursorTheme.name = "Quintom_Ink";
    light.configuration.gtk.cursorTheme.name = "Quintom_Snow";
  };

  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = config.gtk.theme.name;
      "Net/IconThemeName" = config.gtk.iconTheme.name;
    };
  };

  xdg.configFile."gtk-3.0/settings.ini".onChange = "${lib.getExe' pkgs.systemd "systemctl"} --user kill --signal HUP xsettingsd.service";

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
