{
  flake.modules.homeManager.desktop = {
    programs.glide-browser = {
      enable = true;
      profiles = {
        personal = {
          settings."extensions.autoDisableScopes" = 0;
          extensions.force = true;
        };
        alt.id = 1;
      };
    };

    stylix.targets.glide-browser = {
      glideNativeColors.enable = true;
      profileNames = [ "personal" ];
    };

    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/http" = "glide-browser.desktop";
      "x-scheme-handler/https" = "glide-browser.desktop";
      "x-scheme-handler/chrome" = "glide-browser.desktop";
      "text/html" = "glide-browser.desktop";
      "application/pdf" = "glide-browser.desktop";
      "application/x-extension-htm" = "glide-browser.desktop";
      "application/x-extension-html" = "glide-browser.desktop";
      "application/x-extension-shtml" = "glide-browser.desktop";
      "application/xhtml+xml" = "glide-browser.desktop";
      "application/x-extension-xhtml" = "glide-browser.desktop";
      "application/x-extension-xht" = "glide-browser.desktop";
      "application/x-extension-pdf" = "glide-browser.desktop";
    };

    home.persistence."/persist".directories = [
      ".config/glide"
      ".cache/glide"
    ];
  };
}
