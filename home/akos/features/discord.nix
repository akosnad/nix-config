{ pkgs, config, ... }:
let
  legcordSettings = pkgs.writeText "settings.json" (builtins.toJSON {
    windowStyle = "native";
    channel = "stable";
    legcordCSP = true;
    minimizeToTray = true;
    keybinds = [ ];
    multiInstance = false;
    mods = "vencord";
    spellcheck = true;
    performanceMode = "none";
    skipSplash = true;
    inviteWebsocket = true;
    startMinimized = false;
    dynamicIcon = false;
    tray = true;
    customJsBundle = "https://legcord.app/placeholder.js";
    customCssBundle = "https://legcord.app/placeholder.css";
    disableAutogain = false;
    useLegacyCapturer = false;
    mobileMode = false;
    trayIcon = "default";
    doneSetup = true;
    clientName = "Legcord";
    customIcon = "${pkgs.legcord}/opt/Legcord/resources/app.asar/assets/desktop.png";
  });

  withLegcordConfigDir = path: ".config/Legcord/${path}";
in
{
  home.packages = with pkgs; [ legcord ];
  home.file.".config/Legcord/storage/settings.json".source = legcordSettings;
  home.file.".config/Legcord/storage/lang.json".source = pkgs.writeText "lang.json" (builtins.toJSON { lang = "en-US"; });

  xdg.desktopEntries.legcord = {
    name = "Discord";
    genericName = "Discord (Legcord) client";
    exec = "legcord --enable-features=UseOzonePlatform --ozone-platform=wayland";
    type = "Application";
    icon = "discord";
    mimeType = [ "x-scheme-handler/discord" ];
    categories = [ "Network" "InstantMessaging" ];
  };

  home.persistence."/persist/${config.home.homeDirectory}" = {
    directories = map withLegcordConfigDir [ "plugins" "themes" "Local Storage" "Session Storage" ];
    files = map withLegcordConfigDir [ "Cookies" "Preferences" ];
  };
}
