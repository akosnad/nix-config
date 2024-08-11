{ pkgs }:
{
  hass-node-red = pkgs.callPackage ./hass-node-red.nix { inherit pkgs; };
}
