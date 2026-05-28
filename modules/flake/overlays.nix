{ lib, inputs, config, ... }:
let
  overlays = [
    inputs.nur.overlays.default
    inputs.glide.overlays.default
  ]
  ++ (lib.attrValues config.flake.overlays);
in
{
  flake.modules.nixos.base = {
    nixpkgs = { inherit overlays; };
  };

  flake.modules.homeManager.base = {
    nixpkgs = { inherit overlays; };
  };
}
