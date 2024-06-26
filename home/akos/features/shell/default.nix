{ pkgs, ... }:
{
  imports = [
    ./ranger.nix
    ./tmux.nix
    ./gpg.nix
    ./zsh.nix
    ./comma.nix
    ./gh.nix
    ./azure.nix
  ];

  home.packages = with pkgs; [
    ncdu
    jq
    htop
    cachix
    nix-output-monitor
    file
  ];
}
