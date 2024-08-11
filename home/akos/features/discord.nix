{ pkgs, config, ... }:
let
  armcordSettings = pkgs.writeText "settings.json" (builtins.toJSON {
    windowStyle = "native";
    channel = "stable";
    armcordCSP = true;
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
    customJsBundle = "https://armcord.app/placeholder.js";
    customCssBundle = "https://armcord.app/placeholder.css";
    disableAutogain = false;
    useLegacyCapturer = false;
    mobileMode = false;
    trayIcon = "default";
    doneSetup = true;
    clientName = "ArmCord";
    customIcon = "${pkgs.armcord}/opt/ArmCord/resources/app.asar/assets/desktop.png";
  });

  withArmcordConfigDir = path: ".config/ArmCord/${path}";
in
{
  home.packages = with pkgs; [ armcord ];
  home.file.".config/ArmCord/storage/settings.json".source = armcordSettings;
  home.file.".config/ArmCord/storage/lang.json".source = pkgs.writeText "lang.json" (builtins.toJSON { lang = "en-US"; });

  xdg.desktopEntries.armcord = {
    name = "Discord";
    genericName = "Discord (ArmCord) client";
    exec = "armcord --enable-features=UseOzonePlatform --ozone-platform=wayland";
    type = "Application";
    icon = "discord";
    mimeType = [ "x-scheme-handler/discord" ];
    categories = [ "Network" "InstantMessaging" ];
  };

  home.persistence."/persist/${config.home.homeDirectory}" = {
    directories = map withArmcordConfigDir [ "plugins" "themes" "Local Storage" "Session Storage" ];
    files = map withArmcordConfigDir [ "Cookies" "Preferences" ];
  };
}
