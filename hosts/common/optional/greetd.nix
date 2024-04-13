{ lib, config, pkgs, ... }:
let
  homeCfgs = config.home-manager.users;
  homeSharePaths = lib.mapAttrsToList (_: v: "${v.home.path}/share") homeCfgs;
  vars = ''XDG_DATA_DIRS="$XDG_DATA_DIRS:${lib.concatStringsSep ":" homeSharePaths}" GTK_USE_PORTAL=0 GTK_THEME=${gtkTheme.name}'';


  akosConfig = homeCfgs.akos;
  gtkTheme = akosConfig.gtk.theme;
  iconTheme = akosConfig.gtk.iconTheme;
  # wallpaper = akosConfig.wallpaper;

  sway-kiosk = command: "${lib.getExe pkgs.sway} --unsupported-gpu --config ${pkgs.writeText "kiosk.config" ''
    output * bg #000000 solid_color
    border none
    default_border none
    default_floating_border none
    xwayland disable
    input "type:touchpad" {
      tap enabled
    }
    exec '${vars} ${command}; ${pkgs.sway}/bin/swaymsg exit'
  ''}";
in
{
  users.extraUsers.greeter = {
    packages = [
      gtkTheme.package
      iconTheme.package
    ];
    home = "/tmp/greetd-home";
    createHome = true;
  };

  services.greetd = {
    enable = true;
    settings.default_session.command = sway-kiosk (lib.getExe pkgs.greetd.gtkgreet);
  };
}
