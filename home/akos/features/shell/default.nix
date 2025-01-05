{ pkgs, ... }:
{
  imports = [
    ./oh-my-posh.nix
    ./ranger.nix
    ./tmux.nix
    ./gpg.nix
    ./zsh.nix
    ./comma.nix
    ./gh.nix
    ./ssh.nix
    ./cachix.nix
  ];

  home.packages = with pkgs; [
    ncdu
    jq
    htop
    nix-output-monitor
    file
  ];
}
