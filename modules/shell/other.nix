{
  config.flake.modules.homeManager.shell = { pkgs, ... }: {
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
  };
}
