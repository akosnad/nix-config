{ pkgs, ... }:
{
  home.packages = with pkgs; [ kicad ];

  home.persistence."/persist".directories = [
    ".cache/kicad"
    ".local/share/kicad"
    ".config/kicad"
  ];
}
