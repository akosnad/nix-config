{ pkgs, lib, ... }:
let
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
    runtimeInputs = with pkgs; [ swww coreutils ];
    text = ''
      # get currently displayed file
      curr="$(swww query | cut -d' ' -f8 | tail -n1)"

      # select random file other than current
      next_img="$(find "${wallpapersDir}" -type f ! -path "$curr" | sort -R | tail -n1)"
      swww img "$next_img"
    '';
  };
in
{
  systemd.user = {
    services = {
      wallpaper = {
        Unit = {
          Description = "Wallpaper changer";
          Wants = [ "swww.service" ];
          After = [ "swww.service" ];
        };

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

    timers.wallpaper = {
      Unit = {
        Description = "Wallpaper changer interval";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Timer = {
        # every 5 minutes
        OnCalendar = "*:0/5";
        # after login
        OnActiveSec = "2";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };

  services.hyprpaper.enable = lib.mkForce false;
  stylix.targets.hyprpaper.enable = lib.mkForce false;
}
