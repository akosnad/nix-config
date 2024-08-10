{ pkgs }:
{
  google = pkgs.callPackage ./google.nix { inherit pkgs; };
  soft = pkgs.callPackage ./soft.nix { inherit pkgs; };
}
