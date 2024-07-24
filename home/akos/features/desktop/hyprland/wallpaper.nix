{ pkgs, lib, ... }:
let
  swww = lib.getExe pkgs.swww;
  wallpapersDir = pkgs.stdenvNoCC.mkDerivation {
    name = "wallpapers";
    src = ../wallpapers;
    dontUnpack = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      cp -v $src/*.{png,jpg,jpeg} $out
    '';
  };

  wallpaper-changer = pkgs.writeShellApplication {
    name = "wallpaper-changer";
    text = ''
      # get currently displayed file
      curr="$(${swww} query | ${pkgs.coreutils}/bin/cut -d' ' -f8)"

      # select random file other than current
      find "${wallpapersDir}" -type f ! -path "$curr" | \
        ${pkgs.coreutils}/bin/sort -R | \
        ${pkgs.coreutils}/bin/tail -n1 | \
      while read -r file; do
        ${swww} img "''$file"
      done
    '';
  };
in
{
  systemd.user = {
    services = {
      "wallpaper-changer" = {
        Unit.Description = "Wallpaper changer";

        Service = {
          ExecStart = "${lib.getExe wallpaper-changer}";
        };
      };

      swww = {
        Unit = {
          Description = "swww - Wayland Wallpaper Woes";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = "${pkgs.swww}/bin/swww-daemon";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };

    timers."wallpaper-changer" = {
      Unit = {
        Description = "Wallpaper changer interval";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Timer = {
        # every 5 minutes
        OnCalendar = "*:0/5";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
