{ pkgs }:
{
  plotly-graph-card = pkgs.callPackage ./plotly-graph-card { inherit pkgs; };
}
