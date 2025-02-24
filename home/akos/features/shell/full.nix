{ pkgs, ... }:
{
  imports = [
    ./comma.nix
    ./gh.nix
  ];

  home.packages = with pkgs; [
    nix-output-monitor
  ];
}
