{ config, ... }:
{
  sops = {
    gnupg.home = "${config.home.homeDirectory}/.gnupg";
    defaultSopsFile = ../secrets.yaml;
    secrets = {
      test.path = "%r/test";
    };
  };
}
