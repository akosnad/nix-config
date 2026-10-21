{ lib, ... }:
{
  flake.modules.nixos.base = { pkgs, config, ... }:
    {
      config = lib.mkIf config.wsl.enable {
        system.activationScripts.install-windows-terminal-icon = /* bash */ ''
          # we deliberately want to have the single-quoted string here, as it is an argument to powershell,
          # thus it shall not be parsed by bash here. running powershell directly here is possible due to WSL's
          # binfmt handler to run windows host binaries.
          # shellcheck disable=SC2016
          win_appdata="$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command 'echo $env:appdata')"
          win_appdata="$(${lib.getExe pkgs.gnused} 's%^\(.\)\:\\%/mnt/\L\1/%; s%\\%/%g' <<< "$win_appdata" | tr -d '\r')"
          icon_win_path="$win_appdata"/../Local/nixos.ico
          install "${pkgs.nixos-wsl-terminal-icon}/nixos.ico" "$icon_win_path"
        '';
      };
    };
}
