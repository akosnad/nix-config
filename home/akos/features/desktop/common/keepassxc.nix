{ config, ... }:
{
  imports = [
    ../../onedrive.nix
  ];

  programs.keepassxc = {
    enable = true;
    settings = {
      General.DefaultDatabaseFileName = "${config.home.homeDirectory}/OneDrive/keepass.kdbx";

      Browser = {
        Enabled = true;
        SearchInAllDatabases = true;
      };

      FdoSecrets.Enabled = true;

      GUI = {
        MinimizeOnClose = true;
        MinimizeOnStartup = true;
        ShowTrayIcon = true;
        TrayIconAppearance = "colorful";
      };

      PasswordGenerator.Type = 1;

      Security = {
        LockDatabaseIdle = true;
        LockDatabaseInSeconds = 30;
        LockDatabaseMinimize = true;
      };
    };
  };

  xdg.autostart.entries = [
    "${config.programs.keepassxc.package}/share/applications/org.keepassxc.KeePassXC.desktop"
  ];
}
