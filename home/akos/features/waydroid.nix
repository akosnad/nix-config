{ config, ... }:
{
  home.persistence."/persist/${config.home.homeDirectory}".directories = [
    ".local/share/waydroid"
  ];
}
