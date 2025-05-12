{ config, ... }:
{
  programs.spicetify = {
    enable = true;
  };

  home.persistence."/persist/${config.home.homeDirectory}".directories = [
    ".config/spotify"
    ".cache/spotify"
  ];
}
