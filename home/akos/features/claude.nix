{ pkgs, config, ... }:
{
  # TODO: use HM module after upgrade to 25.11
  home.packages = with pkgs; [
    claude-code
  ];

  home.persistence."/persist/${config.home.homeDirectory}" = {
    directories = [ ".claude" ];
    files = [ ".claude.json" ];
  };
}
