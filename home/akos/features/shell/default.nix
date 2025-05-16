{ pkgs, ... }:
{
  imports = [
    ./oh-my-posh.nix
    ./yazi.nix
    ./tmux.nix
    ./ssh.nix
    ./gpg.nix
    ./zsh.nix
    ./comma.nix
  ];

  home.packages = with pkgs; [
    # disk usage tools
    ncdu
    duf
    dust

    # piping, searching, file utilities
    jq
    ripgrep
    file
    fd

    # system monitoring
    htop
    glances

    # network debugging
    iftop
    iperf3
    gping
    curlie
    doggo

    # nix utilities
    nvd
    nix-tree
  ];
}
