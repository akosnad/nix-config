{ lib, ... }:
{
  config.flake.modules.homeManager.desktop = { pkgs, config, ... }: {
    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = lib.mkOverride 50 "Quintom_Ink";
        package = pkgs.quintom-cursor-theme;
      };
      theme.name = lib.mkOverride 50 "adw-gtk3-dark";
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
  };

  config.flake.modules.nixos.desktop = {
    specialisation.light.configuration = {
      home-manager.sharedModules = [{
        gtk = {
          theme.name = lib.mkOverride 40 "adw-gtk3";
          cursorTheme.name = lib.mkOverride 40 "Quintom_Snow";
        };
      }];
    };
  };
}
