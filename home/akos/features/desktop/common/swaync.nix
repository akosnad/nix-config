{ pkgs, ... }:
{
  services.swaync.enable = true;

  xdg.configFile."swaync/style.css".onChange = ''
    ${pkgs.systemd}/bin/systemctl --user reload-or-restart swaync.service
  '';
}
