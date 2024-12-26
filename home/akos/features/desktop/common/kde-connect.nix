{ config, ... }:
{
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  home.persistence."/persist/${config.home.homeDirectory}".directories = [
    ".config/kdeconnect"
  ];
}
