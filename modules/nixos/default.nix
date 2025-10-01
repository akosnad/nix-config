args:
{
  home-assistant = import ./home-assistant;
  devices = import ./devices.nix;
  esphomeConfigurations = import ./esphome-configurations;
  headscale-policy = import ./headscale-policy.nix;
  wsl-gpg = import ./wsl-gpg.nix;
} // (import ./topology-extractors args)
