args:
{
  home-assistant = import ./home-assistant;
  devices = import ./devices.nix;
  esphomeConfigurations = import ./esphome-configurations;
  headscale-policy = import ./headscale-policy.nix;
} // (import ./topology-extractors args)
