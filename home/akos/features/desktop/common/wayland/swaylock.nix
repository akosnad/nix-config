{ config, pkgs, ... }:
{
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      screenshots = true;
      clock = true;

      effect-blur = "20x3";

      # TODO: grace period crashes swaylock-effects for some reason
      #grace = 5;

      fade-in = 4.0;

      font = config.fontProfiles.regular.family;
      font-size = 15;

      line-uses-inside = true;
      disable-caps-lock-text = true;

      indicator-thickness = 7;
      indicator-caps-lock = true;
      indicator-radius = 60;
      indicator-idle-visible = true;
    };
  };
}
