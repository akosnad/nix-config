{ lib, ... }:
{
  flake.modules.homeManager.shell = { config, ... }:
    let
      hasKitty = config.programs.kitty.enable;
    in
    {
      programs.zsh.shellAliases = lib.mkIf hasKitty {
        ssh = "kitten ssh";
      };
    };
}
