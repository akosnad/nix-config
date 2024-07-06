{ config, ... }:
{
  programs.chromium = {
    enable = true;
  };

  home.persistence."/persist/${config.home.homeDirectory}".directories = [ ".config/chromium" ];
}
