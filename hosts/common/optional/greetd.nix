{ lib, config, pkgs, ... }:
let
  homeCfgs = config.home-manager.users;
  homeSharePaths = lib.mapAttrsToList (_: v: "${v.home.path}/share") homeCfgs;
  vars = ''XDG_DATA_DIRS="$XDG_DATA_DIRS:${lib.concatStringsSep ":" homeSharePaths}" GTK_USE_PORTAL=0 GTK_THEME=${gtkTheme.name}'';


  akosConfig = homeCfgs.akos;
  gtkTheme = akosConfig.gtk.theme;
  inherit (akosConfig.gtk) iconTheme;

  swaymsg = "${pkgs.sway}/bin/swaymsg";

  monitor-timeout = pkgs.writeShellApplication {
    name = "greetd-monitor-timeout";
    runtimeInputs = with pkgs; [ sway swayidle jq ];
    text = ''
      monitors="$(swaymsg -t get_outputs | jq -r '.[] | .name')"

      while read -r monitor; do
        echo "starting swayidle for monitor $monitor"
        swayidle -w \
          timeout 30 "${swaymsg} output ""$monitor"" dpms off" \
          resume "${swaymsg} output ""$monitor"" dpms on" &
      done <<< "$monitors"

      wait
    '';
  };

  sway-kiosk = command: "${lib.getExe pkgs.sway} --unsupported-gpu --config ${pkgs.writeText "kiosk.config" ''
    output * bg #000000 solid_color
    default_border none
    default_floating_border none
    xwayland disable
    input "type:touchpad" {
      tap enabled
    }
    exec '${lib.getExe monitor-timeout}'
    exec '${vars} ${command}; ${swaymsg} exit'
  ''}";

  hyprlandConfig = akosConfig.wayland.windowManager.hyprland;
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

  environment.etc."greetd/environments".text = ''
    ${if hyprlandConfig.enable then "Hyprland" else ""}
  '';
}
