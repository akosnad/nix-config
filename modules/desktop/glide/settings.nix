{ lib, ... }:
{
  flake.modules.homeManager.desktop = {
    programs.glide-browser = {
      policies = {
        NoDefaultBookmarks = true;
      };
      profiles.personal.settings = {

        # allow running unsigned extensions.
        "xpinstall.signatures.required" = false;

        # disable first run behaviour.
        # this tries to block some extensions from
        # opening welcome pages
        "app.normandy.first_run" = false;
        "doh-rollout.doneFirstRun" = true;
        "nimbus.firstUpdateComplete" = true;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "trailhead.firstrun.didSeeAboutWelcome" = true;
        "browser.aboutwelcome.enabled" = false;
        "startup.homepage_welcome_url" = "";
        "extensions.pendingOperations" = false;

        # nags, promo and various popup UI elements.
        "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
        "sidebar.toolbarbuttons.introduced.sidebar-button" = true;
        "browser.startup.couldRestoreSession.count" = 2; # restore previous tabs promo

        # topbar and sidebar
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.uidensity" = 1; # compact
        "sidebar.revamp" = true;
        "sidebar.visibility" = "collapsed";
        "sidebar.verticalTabs" = true;
        "browser.uiCustomization.horizontalTabstrip" = builtins.toJSON [
          "tabbrowser-tabs"
          "new-tab-button"
          "alltabs-button"
        ];
        "browser.pageActions.persistedActions" = builtins.toJSON {
          ids = [ "bookmark" ];
          idsInUrlbar = [ "bookmark" ];
          idsInUrlbarPreProton = [ ];
          version = 1;
        };
        "browser.uiCustomization.state" = builtins.toJSON {
          placements = {
            widget-overflow-fixed-list = [ ];
            unified-extensions-area = [
              "firefoxcolor_mozilla_com-browser-action"
              "addon_darkreader_org-browser-action"
            ];
            nav-bar = [
              "sidebar-button"
              "back-button"
              "forward-button"
              "stop-reload-button"
              "glide-toolbar-mode-button"
              "vertical-spacer"
              "customizableui-special-spring1"
              "urlbar-container"
              "reset-pbm-toolbar-button"
              "customizableui-special-spring2"
              "glide-toolbar-keyseq-button"
              "ublock0_raymondhill_net-browser-action"
              "unified-extensions-button"
              "alltabs-button"
              "downloads-button"
            ];
            toolbar-menubar = [ "menubar-items" ];
            TabsToolbar = [ ];
            vertical-tabs = [ "tabbrowser-tabs" ];
            PersonalToolbar = [
              "import-button"
              "personal-bookmarks"
            ];
          };
          seen = [
            "reset-pbm-toolbar-button"
            "firefoxcolor_mozilla_com-browser-action"
            "addon_darkreader_org-browser-action"
            "ublock0_raymondhill_net-browser-action"
            "developer-button"
            "screenshot-button"
          ];
          dirtyAreaCache = [
            "unified-extensions-area"
            "nav-bar"
            "toolbar-menubar"
            "TabsToolbar"
            "vertical-tabs"
            "PersonalToolbar"
          ];
          currentVersion = 24;
          newElementCount = 5;
        };
        "sidebar.main.tools" = lib.concatStringsSep "," [
          "history"
          "bookmarks"
        ];
        "sidebar.backupState" = builtins.toJSON {
          command = "";
          panelOpen = false;
          bookmarksExpandedFolders = [ ];
          launcherWidth = 51; # collapsed sidebar
          launcherExpanded = false;
          launcherVisible = true;
        };
      };
    };
  };
}
