{
  monitors = import ./monitors.nix;
  oh-my-posh = import ./oh-my-posh.nix;
  microsoft-edge = import ./microsoft-edge.nix;
} // (import ../stylix)
