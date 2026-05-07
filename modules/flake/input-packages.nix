{ inputs, ... }:
{
  flake.overlays.obelisk = final: _prev: {
    obelisk = inputs.obelisk.packages.${final.stdenv.hostPlatform.system}.default;
  };
}
