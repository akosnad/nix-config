{ lib, ... }:
{
  config.flake.modules.homeManager.desktop = {
    programs.chromium = {
      enable = true;
      nativeMessagingHosts = lib.mkForce [ ];
    };

    home.persistence."/persist".directories = [ ".config/chromium" ];
  };
}
