{
  services.esphome-updater = {
    enable = true;
  };

  sops.secrets.esphome-secrets = {
    sopsFile = ./secrets.yaml;
  };
}
