{ pkgs, ... }:
{
  imports = [
    ./oh-my-posh.nix
    ./ranger.nix
    ./tmux.nix
    ./ssh.nix
    ./gpg.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    ncdu
    jq
    htop
    file
  ];
}
