{ pkgs, config, ... }:
{
  home.packages = with pkgs; [ kicad ];

  home.persistence."/persist/${config.home.homeDirectory}".directories = [
    ".cache/kicad"
    ".local/share/kicad"
    ".config/kicad"
  ];
}
