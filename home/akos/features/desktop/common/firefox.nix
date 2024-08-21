{ config, pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
      DisplayBookmarksToolbar = "never";
      DisplayMenuBar = "default-off";
      SearchBar = "unified";
    };
    profiles.personal = {
      id = 0;
      settings = {
        "extensions.autoDisableScopes" = 0;
        "browser.ctrlTab.sortByRecentlyUsed" = true;
        "browser.newtabpage.activity-stream.default.sites" = "";
      };
      search = {
        default = "Google";
        engines = {
          "Nix packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@n" ];
          };
        };
      };
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        darkreader
        ublock-origin
        lastpass-password-manager
        sponsorblock
      ];
    };
  };

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/chrome" = "firefox.desktop";
    "text/html" = "firefox.desktop";
    "application/x-extension-htm" = "firefox.desktop";
    "application/x-extension-html" = "firefox.desktop";
    "application/x-extension-shtml" = "firefox.desktop";
    "application/xhtml+xml" = "firefox.desktop";
    "application/x-extension-xhtml" = "firefox.desktop";
    "application/x-extension-xht" = "firefox.desktop";
  };

  home.persistence."/persist/${config.home.homeDirectory}" =
    let
      prefix = ".mozilla/firefox/personal";
      withPrefix = names: map (name: "${prefix}/${name}") names;
    in
    {
      directories = [
        ".mozilla/firefox/default" # old profile
      ] ++ withPrefix [
        "extension-store"
        "extension-store-menus"
        "security_state"
        "sessionstore-backups"
        "settings"
        "storage"
      ];
      files = withPrefix [
        "cookies.sqlite"
        "pkcs11.txt"
        "cert9.db"
        "key4.db"
        "storage.sqlite"
        "permissions.sqlite"
        "times.json"
        "bounce-tracking-protection.sqlite"
        "places.sqlite"
        "favicons.sqlite"
        "SiteSecurityServiceState.bin"
        "AlternateServices.bin"
        "content-prefs.sqlite"
        "storage-sync-v2.sqlite"
        "extension-preferences.json"
        "shield-preference-experiments.json"
        "handlers.json"
        "containers.json"
        "protections.sqlite"
        "addonStartup.json.lz4"
        "webappsstore.sqlite"
        "formhistory.sqlite"
        "extension-settings.json"
        "serviceworker.txt"
        "addons.json"
        "extensions.json"
        "broadcast-listeners.json"
        "sessionstore.jsonlz4"
        "xulstore.json"
        "sessionCheckpoints.json"
      ];
    };
}
