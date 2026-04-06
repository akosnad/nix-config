{ lib, ... }:
{
  flake.modules.nixos.base = {
    i18n = {
      defaultLocale = lib.mkDefault "en_US.UTF-8";
      extraLocaleSettings = {
        LC_TIME = lib.mkDefault "hu_HU.UTF-8";
      };
      supportedLocales = lib.mkDefault [
        "en_US.UTF-8/UTF-8"
        "hu_HU.UTF-8/UTF-8"
      ];
    };
    location.provider = "geoclue2";
    time.timeZone = lib.mkDefault "Europe/Budapest";
  };
}
