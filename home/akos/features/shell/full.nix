{ pkgs, ... }:
{
  imports = [
    ./comma.nix
    ./gh.nix
    ./cachix.nix
  ];

  home.packages = with pkgs; [
    nix-output-monitor
  ];
}
