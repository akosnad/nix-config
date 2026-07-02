{ lib, ... }:
{
  flake.modules.homeManager.desktop = { pkgs, ... }: {
    systemd.user.services.niri-dynamic-border-manager = {
      Unit = {
        PartOf = [ "graphical-session.target" ];
        After = "graphical-session-pre.target";
        X-SwitchMethod = "restart";
      };
      Service.ExecStart = lib.getExe pkgs.niri-dynamic-border-manager;
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
