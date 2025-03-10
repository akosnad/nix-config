{ pkgs, ... }:
{
  imports = [
    ./gh.nix
  ];

  home.packages = with pkgs; [
    nix-output-monitor
  ];
}
