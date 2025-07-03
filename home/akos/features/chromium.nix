{ config, lib, ... }:
{
  programs.chromium = {
    enable = true;
    nativeMessagingHosts = lib.mkForce [ ];
  };

  home.persistence."/persist/${config.home.homeDirectory}".directories = [ ".config/chromium" ];
}
