{ pkgs, config, ... }:
{
  home.packages = with pkgs; [ microsoft-edge ];

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = "microsoft-edge.desktop";
    "x-scheme-handler/https" = "microsoft-edge.desktop";
    "x-scheme-handler/chrome" = "microsoft-edge.desktop";
    "text/html" = "microsoft-edge.desktop";
    "application/x-extension-htm" = "microsoft-edge.desktop";
    "application/x-extension-html" = "microsoft-edge.desktop";
    "application/x-extension-shtml" = "microsoft-edge.desktop";
    "application/xhtml+xml" = "microsoft-edge.desktop";
    "application/x-extension-xhtml" = "microsoft-edge.desktop";
    "application/x-extension-xht" = "microsoft-edge.desktop";
  };

  home.persistence."/persist/${config.home.homeDirectory}".directories = [
    ".config/microsoft-edge"
  ];
}
