# taken from: https://github.com/nix-community/home-manager/blob/095fef2f265c3c0da4fe315efba8f8a04495ab34/modules/programs/noctalia/accounts.nix
{ lib, ... }:
{
  options.noctalia.enable = lib.mkEnableOption "Noctalia access" // {
    description = ''
      Add this calendar to Noctalia's settings as a local vdir account.
      Only filesystem calendars are supported; single-file calendars are
      not included.

      Requires {option}`programs.noctalia.enable` to be enabled and
      {option}`programs.noctalia.settings` to be an attribute set.
      Generated account fields can be overridden through
      {option}`programs.noctalia.settings.calendar.account`.
    '';
  };
}
