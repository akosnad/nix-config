{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    linphone
  ];

  home.persistence."/persist/${config.home.homeDirectory}".directories = [
    ".config/linphone"
    ".local/share/linphone"
  ];
}
