{
  flake.modules.homeManager.desktop = {
    programs.glide-browser.profiles.personal.settings = {

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

      # allow running unsigned extensions
      "xpinstall.signatures.required" = false;
    };
  };
}
