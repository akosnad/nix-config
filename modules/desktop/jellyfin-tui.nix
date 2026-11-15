{
  flake.modules.homeManager.desktop = { pkgs, ... }: {
    home.packages = [ pkgs.jellyfin-tui ];
    home.persistence."/persist".directories = [
      ".local/share/jellyfin-tui"
      ".config/jellyfin-tui"
    ];
  };

  flake.modules.nixos.desktop = {
    services.restic.backups.persist.exclude = [
      "/persist/home/**/.local/share/jellyfin-tui/logs"
    ];
  };
}
