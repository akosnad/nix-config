{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    steamPackages.steamcmd
    steam-run
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
