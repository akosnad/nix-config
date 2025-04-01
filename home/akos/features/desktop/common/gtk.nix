{ config, inputs, pkgs, lib, ... }:
let
  inherit (inputs.nix-colors.lib.contrib { inherit pkgs; }) gtkThemeFromScheme;
in
rec {
  gtk = {
    enable = true;
    font = {
      name = config.fontProfiles.regular.family;
      size = 12;
    };
    theme = {
      name = "${config.colorscheme.slug}";
      package = gtkThemeFromScheme { scheme = config.colorScheme; };
    };
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
      "Net/ThemeName" = gtk.theme.name;
      "Net/IconThemeName" = gtk.iconTheme.name;
    };
  };

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
