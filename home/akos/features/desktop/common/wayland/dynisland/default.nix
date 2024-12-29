{ pkgs, lib, ... }:
let
  dynislandConfig = pkgs.stdenvNoCC.mkDerivation rec {
    name = "dynisland.ron";
    src = ./default.ron;
    phases = "installPhase";
    installPhase = ''
      mkdir -p $out
      cp $src $out/${name}
    '';
  };
  style = pkgs.stdenvNoCC.mkDerivation rec {
    name = "dynisland.scss";
    src = ./default.scss;
    phases = "installPhase";
    installPhase = ''
      mkdir -p $out
      cp $src $out/${name}
    '';
  };

  configDir = pkgs.symlinkJoin {
    name = "dynisland-config";
    paths = [ dynislandConfig style ];
  };
in
{
  home.packages = with pkgs; [
    dynisland
  ];

  xdg.configFile.dynisland = {
    source = configDir;
    onChange = /* bash */ ''
      PIDS="$(${pkgs.procps}/bin/pidof dynisland)";

      if [ -n "$PIDS" ]; then
        ${pkgs.procps}/bin/kill -HUP $PIDS
        ${pkgs.systemd}/bin/systemctl --user reload-or-restart dynisland
      fi
    '';
  };

  systemd.user.services.dynisland = {
    Unit = {
      Description = "dynisland layer shell";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.dynisland} daemon -n";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
