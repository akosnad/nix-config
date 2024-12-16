{ pkgs }:
{
  plotly-graph-card = pkgs.callPackage ./plotly-graph-card { inherit pkgs; };
  wallpanel = pkgs.callPackage ./wallpanel { inherit pkgs; };
  webrtc-camera = pkgs.callPackage ./webrtc-camera.nix { inherit pkgs; };
}
