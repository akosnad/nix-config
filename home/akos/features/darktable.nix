{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    darktable
  ];

  home.persistence."/persist/${config.home.homeDirectory}".directories = [
    ".config/darktable"
  ];
}
