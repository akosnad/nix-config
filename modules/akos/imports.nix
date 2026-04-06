{ config, ... }:
let
  flakeConfig = config;
in
{
  config.flake.modules.homeManager.akos = {
    imports = with flakeConfig.flake.modules.homeManager; [
      shell
      helix
    ];
  };

  config.flake.modules.nixos.akos = {
    imports = with flakeConfig.flake.modules.nixos; [
      shell
    ];
  };
}
