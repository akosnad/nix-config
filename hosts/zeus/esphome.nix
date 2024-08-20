{
  services.esphome = {
    enable = true;
    address = "10.20.0.4";
  };

  environment.persistence."/persist".directories = [{
    directory = "/var/lib/private/esphome";
    mode = "750";
    user = "esphome";
    group = "esphome";
  }];
}
