{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql;
    settings = {
      max_connections = "300";
      shared_buffers = "80MB";
    };
  };

  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
  };
}
