{ pkgs, config, ... }:
{
  home.packages = with pkgs; [ pavucontrol ];

  home.persistence."/persist/${config.home.homeDirectory}".directories = [ ".local/state/wireplumber" ];
}
