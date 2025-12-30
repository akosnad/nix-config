_:
{
  # also enable home manager module for users that use waydroid
  # to have the data partition also persisted!
  #
  # TODO: enable it automatically here for all HM users?

  virtualisation.waydroid.enable = true;

  environment.persistence."/persist".directories = [{
    directory = "/var/lib/waydroid";
    mode = "755";
  }];
}
