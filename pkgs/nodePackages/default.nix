{ pkgs }:
{
  gree-hvac-mqtt-bridge = pkgs.callPackage ./gree-hvac-mqtt-bridge.nix { inherit pkgs; };
}
