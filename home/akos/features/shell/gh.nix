{ config, ... }:
{
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };

  home.persistence."/persist/${config.home.homeDirectory}".files = [ ".config/gh/hosts.yml" ];
}
