{ pkgs }:
{
  hass-node-red = pkgs.callPackage ./hass-node-red.nix { inherit pkgs; };
  ariston-net = pkgs.callPackage ./ariston-net.nix { inherit pkgs; };
  bkk-stop = pkgs.callPackage ./bkk-stop.nix { inherit pkgs; };
  webrtc-camera = pkgs.callPackage ./webrtc-camera.nix { inherit pkgs; };
}
