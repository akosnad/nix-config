{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    languagePacks = [
      "en-US"
      "hu"
    ];
    policies = { };
    profiles.default = {
      settings = {
        # automatically enable extensions on first startup
        "extensions.autoDisableScopes" = 0;

        "font.name.monospace.x-western" = "Recursive Mono Linear Static";
        "font.name.sans-serif.x-western" = "Recursive Sans Linear Static";
        "font.name.serif.x-western" = "Recursive Sans Linear Static";

        "browser.ctrlTab.sortByRecentlyUsed" = true;

        "trailhead.firstrun.didSeeAboutWelcome" = true;
        "browser.aboutConfig.showWarning" = false;
        "app.normandy.first_run" = false;
        "signon.rememberSignons" = false;

        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":["ublock0_raymondhill_net-browser-action","sponsorblocker_ajay_app-browser-action","addon_darkreader_org-browser-action","support_lastpass_com-browser-action","vimium-c_gdh1995_cn-browser-action","webextension_metamask_io-browser-action"],"nav-bar":["back-button","forward-button","stop-reload-button","customizableui-special-spring1","vertical-spacer","urlbar-container","customizableui-special-spring2","downloads-button","unified-extensions-button"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"vertical-tabs":[],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","addon_darkreader_org-browser-action","support_lastpass_com-browser-action","vimium-c_gdh1995_cn-browser-action","ublock0_raymondhill_net-browser-action","sponsorblocker_ajay_app-browser-action","webextension_metamask_io-browser-action","developer-button"],"dirtyAreaCache":["unified-extensions-area","nav-bar","vertical-tabs","PersonalToolbar","widget-overflow-fixed-list","toolbar-menubar","TabsToolbar"],"currentVersion":21,"newElementCount":4}'';

        # allow netwab adapter extension to take over
        "browser.newtab.extensionControlled" = true;
        "browser.startup.homepage" = "chrome://browser/content/blanktab.html";

        "intl.accept_languages" = "en-us,en,hu";
        "intl.locale.requested" = "en-US,hu";

        # allow DRM content
        "media.eme.enabled" = true;
      };
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        lastpass-password-manager
        darkreader
        ublock-origin
        sponsorblock
        vimium-c
        newtab-adapter
        metamask
        reddit-enhancement-suite
      ];
      search = {
        default = "Google";
        engines = {
          "Nix Packages" = {
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
          "NixOS Options" = {
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };
          "Home Manager Options" = {
            urls = [{
              template = "https://home-manager-options.extranix.com";
              params = [
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@hm" ];
          };
        };
      };
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
}
