{ lib
, inputs
, config
, ...
}:
let
  flakeConfig = config;
  overlays = [
    inputs.nur.overlays.default
  ]
  ++ (lib.attrValues flakeConfig.flake.overlays);
in
{
  flake.modules.nixos.base =
    { config, ... }:
    {
      _module.args.pkgsUnstable = import inputs.nixpkgs-unstable {
        inherit (config.nixpkgs.hostPlatform) system;
        inherit overlays;
      };

      nixpkgs.overlays = overlays;
    };


  flake.modules.homeManager.base = { config, ... }: {
    _module.args.pkgsUnstable = import inputs.nixpkgs-unstable {
      inherit (config.nixpkgs) system;
      inherit overlays;
    };
  };
}
