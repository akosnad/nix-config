{ pkgs, ... }:
{
  imports = [
    ./ranger.nix
    ./tmux.nix
    ./gpg.nix
    ./zsh.nix
    ./comma.nix
  ];

  home.packages = with pkgs; [
    ncdu
    jq
    htop
    cachix
    nix-output-monitor
  ];
}
