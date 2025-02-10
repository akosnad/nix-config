{ config, ... }:
{
  # this is to be used along with hosts/common/optional/steam.nix

  home.persistence."/persist/${config.home.homeDirectory}".directories = [
    ".local/share/Steam"
  ];
}
