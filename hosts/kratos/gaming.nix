{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    steamcmd
    steam-run
    mangohud
    lutris
    protonup-ng
  ];
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession = {
      enable = true;
      args = [
        "-W"
        "3840"
        "-H"
        "2160"
        "-f"
        "--force-grab-cursor"
      ];
    };
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
        desiredgov = "performance";
        inhibit_screensaver = 1;
      };

      gpu = {
        amd_performance_level = "high";
      };
    };
  };
}
