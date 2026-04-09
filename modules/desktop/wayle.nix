{ config, ... }:
{
  flake.modules.homeManager.wayle = { pkgsUnstable, ... }: {
    home.packages = [ pkgsUnstable.wayle ];
  };

  flake.modules.homeManager.desktop = {
    imports = [ config.flake.modules.homeManager.wayle ];
  };
}
