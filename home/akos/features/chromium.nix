{ lib, ... }:
{
  programs.chromium = {
    enable = true;
    nativeMessagingHosts = lib.mkForce [ ];
  };

  home.persistence."/persist".directories = [ ".config/chromium" ];
}
