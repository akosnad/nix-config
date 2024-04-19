{ pkgs, ... }:
{
  imports = [
    ./ranger.nix
    ./tmux.nix
    ./gpg.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    ncdu
    jq
    htop
    cachix
  ];
}
