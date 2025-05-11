{
  monitors = import ./monitors.nix;
  oh-my-posh = import ./oh-my-posh.nix;
} // (import ../stylix)
