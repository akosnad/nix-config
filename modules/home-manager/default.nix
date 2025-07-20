{
  monitors = import ./monitors.nix;
  oh-my-posh = import ./oh-my-posh.nix;
  microsoft-edge = import ./microsoft-edge.nix;
  sops-cmd-wrapper = import ./sops-cmd-wrapper.nix;
} // (import ../stylix)
