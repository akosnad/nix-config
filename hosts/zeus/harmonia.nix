{ config, ... }:
{
  services.harmonia = {
    enable = true;
    signKeyPath = config.sops.secrets.harmonia-key.path;
  };
  nix.settings.allowed-users = [ "harmonia" ];

  sops.secrets.harmonia-key = {
    sopsFile = ./secrets.yaml;
  };
}
