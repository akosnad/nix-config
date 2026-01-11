{ pkgs, ... }:
{
  home.packages = with pkgs; [
    darktable
  ];

  home.persistence."/persist".directories = [
    ".config/darktable"
  ];
}
