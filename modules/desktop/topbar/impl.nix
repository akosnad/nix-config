{ config, ... }:
{
  flake.modules.homeManager.desktop.imports = [ config.flake.modules.homeManager.noctalia ];
  flake.modules.nixos.desktop.imports = [ config.flake.modules.nixos.noctalia ];
}
