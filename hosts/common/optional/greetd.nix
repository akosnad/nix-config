{ lib, config, pkgs, ... }:
let
  homeCfgs = config.home-manager.users;

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
    exec '${command}; ${swaymsg} exit'
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
    settings.default_session.command = sway-kiosk (lib.getExe config.programs.regreet.package);
  };

  programs.regreet = {
    enable = true;
    settings = {
      background.path = lib.mkForce "";
      appearance.greeting_msg = "";
      widget.clock = {
        format = "%Y. %m. %d. %H:%M";
        timezone = config.time.timeZone;
      };
    };
  };

  environment.etc."greetd/environments".text = ''
    ${if hyprlandConfig.enable then "Hyprland" else ""}
  '';
}
