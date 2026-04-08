{ lib, inputs, config, ... }:
{
  flake.modules.nixos.base = {
    nixpkgs.overlays = [
      inputs.nur.overlays.default
    ]
    ++ (lib.attrValues config.flake.overlays);
  };
}
