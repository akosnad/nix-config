{ lib, ... }:
{
  config.flake.modules.homeManager.desktop =
    { pkgs
    , config
    , ...
    }:
    let
      wallpapersDir = pkgs.stdenvNoCC.mkDerivation {
        name = "wallpapers";
        src = ./wallpapers;
        dontUnpack = true;
        dontBuild = true;
        installPhase = ''
          mkdir -p $out
          cp -v $src/*.{png,jpg,jpeg} $out
        '';
      };

      wallpaper-changer = pkgs.writeShellApplication {
        name = "wallpaper-changer";
        runtimeInputs = with pkgs; [
          awww
          coreutils
        ];
        text = ''
          # get currently displayed file
          curr="$(awww query | cut -d' ' -f8 | tail -n1)"

          # select random file other than current
          next_img="$(find "${wallpapersDir}" -type f ! -path "$curr" | sort -R | tail -n1)"
          ${lib.pipe config.monitors [
            (lib.filter (m: m.enabled))
            (map (m: "awww img -o ${m.name} \"$next_img\""))
            (lib.concatStringsSep "\n")
          ]}
        '';
      };
    in
    {
      systemd.user = {
        services = {
          wallpaper = {
            Unit = {
              Description = "Wallpaper changer";
              Wants = [ "awww.service" ];
              After = [ "awww.service" ];
            };

            Service = {
              ExecStart = "${lib.getExe wallpaper-changer}";
            };
          };

          awww = {
            Unit = {
              Description = "awww - An Answer to your Wayland Wallpaper Woes";
              After = [ "graphical-session-pre.target" ];
              PartOf = [ "graphical-session.target" ];
            };

            Service = {
              ExecStart = lib.getExe' pkgs.awww "awww-daemon";
              ExecStartPost = "${lib.getExe pkgs.awww} clear ${config.lib.stylix.colors.base00}";
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
    };
}
