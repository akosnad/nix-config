{ lib, ... }:
{
  programs.microsoft-edge = {
    enable = true;
    nativeMessagingHosts = lib.mkForce [ ];
  };

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = "microsoft-edge.desktop";
    "x-scheme-handler/https" = "microsoft-edge.desktop";
    "x-scheme-handler/chrome" = "microsoft-edge.desktop";
    "text/html" = "microsoft-edge.desktop";
    "application/pdf" = "microsoft-edge.desktop";
    "application/x-extension-htm" = "microsoft-edge.desktop";
    "application/x-extension-html" = "microsoft-edge.desktop";
    "application/x-extension-shtml" = "microsoft-edge.desktop";
    "application/xhtml+xml" = "microsoft-edge.desktop";
    "application/x-extension-xhtml" = "microsoft-edge.desktop";
    "application/x-extension-xht" = "microsoft-edge.desktop";
    "application/x-extension-pdf" = "microsoft-edge.desktop";
  };

  home.persistence."/persist".directories = [
    ".config/microsoft-edge"
    ".cache/Microsoft/Edge"
    ".cache/microsoft-edge"
  ];
}
