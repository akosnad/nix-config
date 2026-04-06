{ inputs, ... }:
{
  flake.modules.nixos.base = {
    nixpkgs.overlays = [
      inputs.nur.overlays.default
    ];
  };
}
