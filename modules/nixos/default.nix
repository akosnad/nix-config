args:
{
  home-assistant = import ./home-assistant;
  devices = import ./devices.nix;
  esphome-updater = import ./esphome-updater;
  headscale-policy = import ./headscale-policy.nix;
  wsl-gpg = import ./wsl-gpg.nix;
} // (import ./topology-extractors args)
